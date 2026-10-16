#!/usr/bin/env python3
"""Check SwiftPM/llvm-cov line coverage for Sources/Enigmatic only."""
import argparse
import json
from pathlib import Path


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("report", type=Path)
    parser.add_argument("--minimum", type=float, default=90.0)
    parser.add_argument("--badge-output", type=Path, help="Write a Shields endpoint JSON badge")
    args = parser.parse_args()
    if not 0 <= args.minimum <= 100:
        parser.error("--minimum must be between 0 and 100")
    report = json.loads(args.report.read_text())
    files = {
        item["filename"]: item["summary"]["lines"]
        for data in report["data"]
        for item in data["files"]
        if "/Sources/Enigmatic/" in item["filename"].replace("\\", "/")
    }
    count = sum(item["count"] for item in files.values())
    covered = sum(item["covered"] for item in files.values())
    if not count:
        raise SystemExit("No executable library lines found in coverage report")
    percent = 100 * covered / count
    print(f"Sources/Enigmatic: {covered}/{count} lines ({percent:.2f}%), minimum {args.minimum:.2f}%")
    if args.badge_output:
        args.badge_output.parent.mkdir(parents=True, exist_ok=True)
        args.badge_output.write_text(json.dumps({
            "schemaVersion": 1,
            "label": "coverage",
            "message": f"{percent:.2f}%",
            "color": "brightgreen" if percent >= args.minimum else "red",
        }) + "\n")
    raise SystemExit(0 if percent >= args.minimum else 1)


if __name__ == "__main__":
    main()
