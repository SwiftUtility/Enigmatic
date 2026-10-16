#!/usr/bin/env python3
"""Validate stable release versions and gate public API changes before publication."""
import argparse
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import tempfile


VERSION = re.compile(r"v(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)")


def git(*args):
    return subprocess.check_output(["git", *args], text=True).strip()


def parse_version(tag):
    match = VERSION.fullmatch(tag)
    if not match:
        raise ValueError("Expected a stable version such as v3.0.0 (no leading zeroes or suffixes)")
    return tuple(map(int, match.groups()))


def release_plan(version, tags):
    candidate = parse_version(version)
    stable = []
    for tag in tags:
        if VERSION.fullmatch(tag):
            stable.append((parse_version(tag), tag))
    if not stable:
        return "", "major"
    previous, baseline = max(stable)
    if candidate <= previous:
        raise ValueError(f"Release {version} must be greater than {baseline}")
    if candidate[0] != previous[0]:
        if candidate[1:] != (0, 0):
            raise ValueError("A major bump must reset minor and patch to zero")
        return baseline, "major"
    if candidate[1] != previous[1]:
        if candidate[2] != 0:
            raise ValueError("A minor bump must reset patch to zero")
        return baseline, "minor"
    return baseline, "patch"


def check_version(version):
    baseline, bump = release_plan(version, git("tag", "--list").splitlines())
    # Resolve the baseline now so every matrix job compares with the same commit.
    revision = git("rev-parse", f"{baseline}^{{commit}}") if baseline else ""
    print(f"Release {version}: {bump}, baseline {baseline or '(first release)'}", flush=True)
    if output := os.environ.get("GITHUB_OUTPUT"):
        with open(output, "a") as stream:
            stream.write(f"baseline={revision}\nbump={bump}\n")


def public_api(folder):
    main = list(folder.rglob("Enigmatic.symbols.json"))
    if len(main) != 1:
        raise ValueError(f"Expected exactly one Enigmatic symbol graph in {folder}")
    graphs = [main[0], *sorted(main[0].parent.glob("Enigmatic@*.symbols.json"))]
    symbols = {}
    relationships = set()
    for path in graphs:
        graph = json.loads(path.read_text())
        if graph["module"]["name"] != "Enigmatic":
            raise ValueError(f"Unexpected module in {path}")
        for symbol in graph["symbols"]:
            if symbol["accessLevel"] not in ("public", "open"):
                continue
            # Ignore documentation and source positions, but retain declarations,
            # availability, generic constraints, and external-type extensions.
            symbol = {k: v for k, v in symbol.items() if k not in ("docComment", "location")}
            identifier = symbol["identifier"]["precise"]
            encoded = json.dumps(symbol, sort_keys=True)
            if identifier in symbols and symbols[identifier] != encoded:
                raise ValueError(f"Conflicting symbol graph entries: {identifier}")
            symbols[identifier] = encoded
        relationships.update(json.dumps(item, sort_keys=True) for item in graph["relationships"])
    if not symbols:
        raise ValueError("The public API symbol graph is empty")
    return symbols, relationships


def compare_api(baseline, current, bump="patch"):
    old, old_relationships = public_api(baseline)
    new, new_relationships = public_api(current)
    if bump == "minor":
        protocols = {
            identifier for identifier, symbol in old.items()
            if json.loads(symbol).get("kind", {}).get("identifier") == "swift.protocol"
        }

        def requirements(relationships):
            return {
                (item["source"], item["target"], item["kind"])
                for item in map(json.loads, relationships)
                if item["kind"] in ("requirementOf", "optionalRequirementOf")
                and item["target"] in protocols
            }

        added = requirements(new_relationships) - requirements(old_relationships)
        if added:
            names = []
            for source, target, _ in sorted(added):
                symbol = json.loads(new[source]) if source in new else {}
                names.append(".".join(symbol.get("pathComponents", [source])) + f" (protocol {target})")
            raise ValueError(
                "Minor releases must not add requirements to existing public protocols, "
                "even with default implementations:\n" + "\n".join(names)
            )
        return
    changes = []
    for identifier in sorted(old.keys() | new.keys()):
        if identifier not in old:
            changes.append(f"Added: {identifier}")
        elif identifier not in new:
            changes.append(f"Removed: {identifier}")
        elif old[identifier] != new[identifier]:
            changes.append(f"Changed: {identifier}")
    for item in sorted(new_relationships - old_relationships):
        changes.append(f"Added API relationship: {item}")
    for item in sorted(old_relationships - new_relationships):
        changes.append(f"Removed API relationship: {item}")
    if changes:
        raise ValueError("Patch releases must preserve the public API:\n" + "\n".join(changes))


def dump_api(package, scratch):
    options = ["--package-path", str(package), "--scratch-path", str(scratch)]
    subprocess.run(["swift", "build", *options, "--target", "Enigmatic"], check=True)
    binary = Path(subprocess.check_output([
        "swift", "build", *options, "--show-bin-path",
    ], text=True).strip())
    target = json.loads(subprocess.check_output(["swift", "-print-target-info"], text=True))
    output = scratch / "public-api"
    output.mkdir()
    # Extract only the library: SwiftPM's dump-symbol-graph also tries to load
    # generated test runners, which need not exist in a clean baseline build.
    command = [
        "swift", "symbolgraph-extract", "-module-name", "Enigmatic",
        "-I", str(binary / "Modules"), "-target", target["target"]["triple"],
        "-minimum-access-level", "public", "-skip-inherited-docs",
        "-module-cache-path", str(scratch / "ModuleCache"), "-output-dir", str(output),
    ]
    if sys.platform == "darwin":
        sdk = subprocess.check_output(["xcrun", "--show-sdk-path"], text=True).strip()
        command.extend(["-sdk", sdk])
    subprocess.run(command, check=True)


def check_api(baseline, bump):
    if bump == "major":
        print("Major release: public API changes are allowed")
        return
    if not baseline:
        raise ValueError("Patch and minor checks require a baseline revision")
    subprocess.run([
        "swift", "package", "diagnose-api-breaking-changes", baseline, "--products", "Enigmatic",
    ], check=True)
    with tempfile.TemporaryDirectory(prefix="enigmatic-release-api-") as temp:
        root = Path(temp)
        package = root / "baseline"
        package.mkdir()
        archive = root / "baseline.tar"
        subprocess.run(["git", "archive", baseline, "--output", str(archive)], check=True)
        subprocess.run(["tar", "-xf", str(archive), "-C", str(package)], check=True)
        dump_api(package, root / "baseline-build")
        dump_api(Path.cwd(), root / "current-build")
        compare_api(root / "baseline-build", root / "current-build", bump)
    print(f"Public API check passed for {bump} release")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest="command", required=True)
    version = commands.add_parser("version")
    version.add_argument("version")
    api = commands.add_parser("api")
    api.add_argument("--baseline", default="")
    api.add_argument("--bump", choices=("patch", "minor", "major"), required=True)
    args = parser.parse_args()
    try:
        if args.command == "version":
            check_version(args.version)
        else:
            check_api(args.baseline, args.bump)
    except (ValueError, subprocess.CalledProcessError) as error:
        raise SystemExit(str(error)) from error


if __name__ == "__main__":
    main()
