"""The coverage gate must ignore tests and fail closed on empty reports."""
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

SCRIPT = Path(__file__).resolve().parents[1] / "check-coverage.py"


class CoverageGateTests(unittest.TestCase):
    def run_gate(self, files, minimum=85):
        with tempfile.TemporaryDirectory() as folder:
            report = Path(folder) / "coverage.json"
            report.write_text(json.dumps({"data": [{"files": files}]}))
            return subprocess.run(
                [sys.executable, str(SCRIPT), str(report), "--minimum", str(minimum)],
                capture_output=True, text=True,
            )

    @staticmethod
    def file(path, count, covered):
        return {"filename": path, "summary": {"lines": {"count": count, "covered": covered}}}

    def test_threshold_is_inclusive_and_tests_are_excluded(self):
        result = self.run_gate([
            self.file("/repo/Sources/Enigmatic/A.swift", 100, 85),
            self.file("/repo/Tests/EnigmaticTests/A.swift", 1000, 0),
        ])
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("85/100", result.stdout)

    def test_below_threshold_fails_even_with_fully_covered_tests(self):
        result = self.run_gate([
            self.file("/repo/Sources/Enigmatic/A.swift", 1000, 849),
            self.file("/repo/Tests/EnigmaticTests/A.swift", 1000, 1000),
        ])
        self.assertEqual(result.returncode, 1)

    def test_empty_library_report_fails(self):
        result = self.run_gate([self.file("/repo/Tests/Test.swift", 1, 1)])
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("No executable library lines", result.stderr)

    def test_invalid_threshold_fails(self):
        self.assertNotEqual(self.run_gate([], minimum=101).returncode, 0)


if __name__ == "__main__":
    unittest.main()
