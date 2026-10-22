#!/bin/bash
set -euo pipefail
benchmark_dir="$(cd -- "$(dirname -- "$0")" && pwd)"
repo_dir="$(cd -- "$benchmark_dir/.." && pwd)"
export SWIFTPM_MODULECACHE_OVERRIDE="${SWIFTPM_MODULECACHE_OVERRIDE:-${TMPDIR:-/tmp}/enigmatic-benchmark-module-cache}"
export CLANG_MODULE_CACHE_PATH="$SWIFTPM_MODULECACHE_OVERRIDE"
# The lockfile makes repeated runs use the same dependency revisions.
swift run --package-path "$benchmark_dir" --disable-sandbox -c release Comparison \
  --package-root "$benchmark_dir" \
  --output "$repo_dir/Sources/Enigmatic/Enigmatic.docc/CompetitorBenchmarks.md" "$@"
