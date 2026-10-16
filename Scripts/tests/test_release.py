"""Release gates must reject incompatible version and public API changes."""
from copy import deepcopy
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest


SCRIPT = Path(__file__).resolve().parents[1] / "check-release.py"
SPEC = importlib.util.spec_from_file_location("release_gate", SCRIPT)
GATE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(GATE)


class ReleaseVersionTests(unittest.TestCase):
    def test_stable_versions_are_compared_numerically(self):
        tags = ["v2.9.9", "v2.10.0", "v3.0.0-rc.1", "unrelated"]
        for version, bump in [("v2.10.1", "patch"), ("v2.11.0", "minor"), ("v3.0.0", "major")]:
            with self.subTest(version=version):
                self.assertEqual(GATE.release_plan(version, tags), ("v2.10.0", bump))

    def test_existing_and_lower_versions_are_rejected(self):
        for version in ("v2.0.1", "v2.0.0", "v1.9.9"):
            with self.subTest(version=version), self.assertRaises(ValueError):
                GATE.release_plan(version, ["v2.0.1"])

    def test_bumps_reset_lower_components(self):
        for version in ("v2.1.1", "v3.0.1", "v3.1.0"):
            with self.subTest(version=version), self.assertRaises(ValueError):
                GATE.release_plan(version, ["v2.0.1"])

    def test_invalid_and_unsupported_versions_are_rejected(self):
        for version in ("v", "3.0.0", "v01.0.0", "v1.01.0", "v1.0.01", "v1.2", "v1.0.0\n",
                        "v1.0.0-rc.1", "v1.0.0+build", "v1.0.0;echo bad"):
            with self.subTest(version=version), self.assertRaises(ValueError):
                GATE.parse_version(version)

    def test_first_release_has_no_baseline(self):
        self.assertEqual(GATE.release_plan("v1.0.0", ["unrelated"]), ("", "major"))


class PublicAPITests(unittest.TestCase):
    def graph(self):
        return {
            "module": {"name": "Enigmatic"},
            "symbols": [{
                "identifier": {"precise": "s:example"},
                "accessLevel": "public",
                "declarationFragments": [{"kind": "text", "spelling": "func example() -> Int"}],
                "docComment": {"lines": [{"text": "Old docs"}]},
                "location": {"uri": "file:///old/path.swift", "position": {"line": 1}},
            }],
            "relationships": [],
        }

    def compare(self, old, new, extension=None, bump="patch"):
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            for name, graph in (("old", old), ("new", new)):
                path = root / name
                path.mkdir()
                (path / "Enigmatic.symbols.json").write_text(json.dumps(graph))
            if extension:
                (root / "new" / "Enigmatic@Swift.symbols.json").write_text(json.dumps(extension))
            GATE.compare_api(root / "old", root / "new", bump)

    def protocol_graph(self, requirement_kind="requirementOf"):
        graph = self.graph()
        protocol = {
            "identifier": {"precise": "s:protocol"},
            "accessLevel": "public",
            "kind": {"identifier": "swift.protocol"},
        }
        graph["symbols"].append(protocol)
        graph["relationships"].append({
            "kind": requirement_kind, "source": "s:example", "target": "s:protocol",
        })
        return graph

    def test_minor_rejects_new_requirements_in_existing_protocols(self):
        for kind in ("requirementOf", "optionalRequirementOf"):
            with self.subTest(kind=kind):
                new = self.protocol_graph(kind)
                old = deepcopy(new)
                # The method already existed as an extension member; turning
                # it into a requirement must also be rejected.
                old["relationships"] = []
                new["relationships"].append({
                    "kind": "defaultImplementationOf", "source": "s:default", "target": "s:example",
                })
                with self.assertRaisesRegex(ValueError, "even with default implementations"):
                    self.compare(old, new, bump="minor")

    def test_minor_allows_requirements_of_new_protocols(self):
        old = self.graph()
        new = self.protocol_graph()
        self.compare(old, new, bump="minor")

    def test_minor_allows_existing_requirements_and_new_extension_methods(self):
        old = self.protocol_graph()
        new = deepcopy(old)
        added = deepcopy(new["symbols"][0])
        added["identifier"]["precise"] = "s:extensionMethod"
        new["symbols"].append(added)
        new["relationships"].append({
            "kind": "memberOf", "source": "s:extensionMethod", "target": "s:protocol",
        })
        self.compare(old, new, bump="minor")

    def test_documentation_and_source_moves_do_not_change_api(self):
        old = self.graph()
        new = deepcopy(old)
        new["symbols"][0]["docComment"] = {"lines": [{"text": "New docs"}]}
        new["symbols"][0]["location"] = {"uri": "file:///new/path.swift", "position": {"line": 99}}
        self.compare(old, new)

    def test_patch_rejects_public_additions(self):
        old = self.graph()
        new = deepcopy(old)
        added = deepcopy(new["symbols"][0])
        added["identifier"]["precise"] = "s:added"
        new["symbols"].append(added)
        with self.assertRaisesRegex(ValueError, "Added:"):
            self.compare(old, new)
        with self.assertRaisesRegex(ValueError, "Removed:"):
            self.compare(new, old)

    def test_patch_rejects_signature_availability_and_generic_changes(self):
        for field, value in (
            ("declarationFragments", [{"kind": "text", "spelling": "func example() -> String"}]),
            ("availability", [{"domain": "macOS", "introduced": {"major": 26}}]),
            ("swiftGenerics", {"constraints": [{"kind": "conformance", "lhs": "T", "rhs": "Hashable"}]}),
        ):
            with self.subTest(field=field):
                old = self.graph()
                new = deepcopy(old)
                new["symbols"][0][field] = value
                with self.assertRaisesRegex(ValueError, "Changed:"):
                    self.compare(old, new)

    def test_patch_rejects_new_conformances_and_extension_members(self):
        old = self.graph()
        new = deepcopy(old)
        new["relationships"].append({"kind": "conformsTo", "source": "s:example", "target": "s:Se"})
        with self.assertRaisesRegex(ValueError, "Added API relationship:"):
            self.compare(old, new)
        extension = self.graph()
        extension["symbols"][0]["identifier"]["precise"] = "s:externalExtension"
        with self.assertRaisesRegex(ValueError, "Added:"):
            self.compare(old, old, extension)

    def test_internal_additions_are_ignored(self):
        old = self.graph()
        new = deepcopy(old)
        added = deepcopy(new["symbols"][0])
        added["identifier"]["precise"] = "s:internal"
        added["accessLevel"] = "internal"
        new["symbols"].append(added)
        self.compare(old, new)

    def test_empty_graph_is_rejected(self):
        empty = self.graph()
        empty["symbols"] = []
        with self.assertRaisesRegex(ValueError, "empty"):
            self.compare(empty, empty)


if __name__ == "__main__":
    unittest.main()
