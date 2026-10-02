#!/usr/bin/env python3
"""Check SwiftPM/llvm-cov line coverage for Sources/Enigmatic only."""
import argparse
import json
from pathlib import Path


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("report", type=Path)
    parser.add_argument("--minimum", type=float, default=85.0)
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
    raise SystemExit(0 if percent >= args.minimum else 1)


if __name__ == "__main__":
    main()
