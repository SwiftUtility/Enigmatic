# Development

Run functional tests in Debug and Release:

```sh
swift test --skip PerformanceTests
swift test -c release --skip PerformanceTests
```

On Windows, use Developer PowerShell for Visual Studio with the C++ tools and
Windows SDK installed. Start a fresh shell after installing Swift so `PATH` and
`SDKROOT` include the toolchain and its SDK.

The functional suite passed locally in Debug and Release on Windows x64 with
Swift 6.4.1 on 2026-10-16. Windows is not currently part of the CI matrix.

Local Windows x64 validation with Swift 6.4.1 encountered two toolchain issues:
the default build system failed to find `stdlib.h`, and the compiler's debug-type
round-trip check asserted on negative integer generic arguments in the strategy
tests. To reproduce the successful validation, use:

```powershell
$windowsSwiftFlags = @(
  '--build-system', 'native',
  '-Xswiftc', '-Xfrontend', '-Xswiftc', '-disable-round-trip-debug-types'
)
swift test @windowsSwiftFlags --skip PerformanceTests
swift test @windowsSwiftFlags -c release --skip PerformanceTests
```

These are toolchain workarounds, not package settings. The native build system is
deprecated; recheck these workarounds when updating Swift. Windows validation
does not replace the macOS and Linux CI jobs below.

CI uses Swift 6.3.3 from Xcode 26.6 on macOS 26 and the `swift:6.3.3`
container on Ubuntu 24.04. Each job verifies the compiler version before testing.
The macOS Debug job also checks the coverage script, enforces 95% library line
coverage, and builds DocC. It uploads the coverage report as `coverage.json` and
the documentation as `Enigmatic.doccarchive.tar.gz`, preserving DocC filenames
inside the archive.

The Release workflow publishes the DocC site to GitHub Pages after all release
validation jobs pass and before creating the GitHub release. The site is at
<https://swiftutility.github.io/Enigmatic/documentation/enigmatic/>. Enable
**Settings → Pages → Build and deployment → Source: GitHub Actions** in the
repository before the first deployment. Regular CI runs, including pushes to
`main`, only build documentation artifacts and never deploy the site.

The README coverage badge reads `coverage-badge.json` from the same Pages site.
It reports actual library line coverage from the last successful release
documentation deployment. Documentation and coverage links become available
after the first successful Pages deployment.

CI runs automatically for pushes to `main`. To check a pull request, start
**Actions → Checks → Run workflow** and select its source branch. Pull requests
and pushes to other branches do not start CI automatically.

```sh
python3 -m unittest discover -s Scripts/tests
swift test --enable-code-coverage --skip PerformanceTests
python3 Scripts/check-coverage.py "$(swift test --show-codecov-path)" --minimum 95
```

Benchmarks run separately without coverage. They report relative timings without
CI timing thresholds. Start them independently from
**Actions → Benchmarks → Run workflow** and select the branch to measure.
The workflow uploads `benchmarks.log` with the results. Checks and Benchmarks must
be present on the default branch for their **Run workflow** buttons to appear.

```sh
swift test -c release --filter PerformanceTests
```

Build documentation with Xcode's documentation compiler. Set `enigmatic_symbols`
to the directory printed by `dump-symbol-graph`; the location depends on SwiftPM's
build system. Copy only the library graphs, since SwiftPM can also emit a
test-runner graph after tests have been built.

```sh
swift package dump-symbol-graph --minimum-access-level public
enigmatic_symbols="<symbol-graph directory printed above>"
mkdir -p .build/Enigmatic.symbolgraph
cp "$enigmatic_symbols/Enigmatic.symbols.json" \
  "$enigmatic_symbols"/Enigmatic@*.symbols.json .build/Enigmatic.symbolgraph/
xcrun docc convert Sources/Enigmatic/Enigmatic.docc \
  --additional-symbol-graph-dir .build/Enigmatic.symbolgraph \
  --output-path .build/Enigmatic.doccarchive --warnings-as-errors
```

README examples are exercised in `DocumentationExamplesTests`. Check new
examples against the public API, and keep detailed behavior in the DocC guides.

Start a release from **Actions → Release → Run workflow**. Select the branch
to release and enter a new version starting with `v`, such as `v3.0.0`.
The workflow must be present on the default branch for the button to appear.

The workflow rejects invalid or existing tags, runs Debug and Release tests on
both CI platforms, and enforces coverage on macOS. It then deploys documentation
and the coverage badge to GitHub Pages. Only after successful deployment does it
create the tag on the exact commit that was tested and publish a GitHub release
with generated notes. Failed checks or deployment leave the tag and release
uncreated. Only one Release run executes at a time. At most one additional run
can wait; a newer request replaces the pending run. Dispatch order is not
guaranteed, so wait for one release to finish before starting the next version.
If release creation fails after deployment, the deployed site is not rolled back.
You can edit the release notes afterward in GitHub Releases.

Release versions use the stable `vMAJOR.MINOR.PATCH` format without leading
zeroes; prerelease and build suffixes are not supported by this workflow.
The new version must be greater than the highest stable version tag. A minor
bump resets patch to zero; a major bump resets minor and patch to zero.
The baseline commit is pinned before the validation jobs start.

For patch and minor releases, SwiftPM's `diagnose-api-breaking-changes` checks
the library against that baseline on both macOS and Linux. Patch releases also
compare public symbol graphs, including declarations, availability, generic
constraints, and conformances, while ignoring documentation and source locations.
Any API additions, removals, or changes represented in those graphs reject a
patch release. Minor releases permit compatible additions, but cannot add
requirements to existing public protocols, even with default implementations.
This stricter rule avoids potential name conflicts in client conformances.
Requirements of entirely new protocols are allowed in minor releases.
Major releases skip the API gate. The first stable release has no API baseline.

These checks cover the API exposed on the two CI platforms. They do not prove
behavioral compatibility or validate APIs specific to other Apple platforms.
Review serialization contracts and runtime/toolchain requirements separately.
