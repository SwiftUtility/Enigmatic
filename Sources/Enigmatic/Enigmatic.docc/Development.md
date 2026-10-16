# Development

Run functional tests in Debug and Release:

```sh
swift test --skip PerformanceTests
swift test -c release --skip PerformanceTests
```

To check Linux compatibility with the minimum compiler version from macOS, run
the functional suite in the official Swift Docker image. The source mount is
read-only; build artifacts stay in the container:

```sh
docker run --rm -v "$PWD:/package:ro" -w /package swift:6.1.0 \
  swift test --scratch-path /tmp/enigmatic-build --skip PerformanceTests
docker run --rm -v "$PWD:/package:ro" -w /package swift:6.1.0 \
  swift test --scratch-path /tmp/enigmatic-build -c release --skip PerformanceTests
```

These commands pin the original Swift 6.1 release. The shorter `swift:6.1` tag
can resolve to a later 6.1 patch release. Local validation with Swift 6.1 on
macOS and Windows remains outstanding.
The generic Unix date strategies and their tests are compiled only with Swift
6.2.3 or newer; use the named seconds/milliseconds strategies on older compilers.

The manifest enables `AnyAppleOSAvailability` only with Swift 6.3, where it is
experimental. Swift 6.4 supports `anyAppleOS` without the flag. Earlier compilers
use the explicit Apple platform fallbacks in conditional compilation guards.

On Windows, use Developer PowerShell for Visual Studio with the C++ tools and
Windows SDK installed. Start a fresh shell after installing Swift so `PATH` and
`SDKROOT` include the toolchain and its SDK.

The functional suite passed locally in Debug and Release on Windows x64 with
Swift 6.4.1 on 2026-10-16.

Windows CI with Swift 6.2.3 and 6.4.1 needs the compiler's debug-type round-trip
check disabled for negative integer generic arguments in the strategy tests.
Swift 6.4.1 also needs the native build system because the default build system
failed to find `stdlib.h`. To reproduce the successful local 6.4.1 validation, use:

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

The Windows Swift 6.1 compiler also asserts while generating `Each`'s encoding
witness for a tuple pack ([Swift issue #79870](https://github.com/swiftlang/swift/issues/79870)).
A helper keeps the tuple inside `Codec.Box` across that
witness boundary on Windows with Swift 6.1. Other compilers use the direct path.

The Checks workflow runs each compiler independently on all three platforms in
Debug and Release, producing 18 builds:

| Swift | macOS | Linux (`ubuntu-24.04`) | Windows (`windows-2022`) |
| --- | --- | --- | --- |
| 6.1 | `macos-15`, Xcode 16.3 | `swift:6.1.0` | `swift-6.1-RELEASE` installer |
| 6.2.3 | `macos-26`, Xcode 26.2 | `swift:6.2.3` | `swift-6.2.3-RELEASE` installer |
| 6.4.1 | `macos-26`, official 6.4.1 toolchain with Xcode 26.6's SDK | `swift:6.4.1` | `swift-6.4.1-RELEASE` installer |

Benchmarks uses Xcode 26.3.
Each job verifies its compiler version before testing. The 6.1 builds require
the original release (reported as 6.1 or 6.1.0), rejecting later patch versions.
The macOS 6.2.3 Debug job also checks the coverage script, enforces 95% library line
coverage, and builds DocC. It uploads the coverage report as `coverage.json` and
the documentation as `Enigmatic.doccarchive.tar.gz`, preserving DocC filenames
inside the archive.

All Windows toolchains use Visual Studio's C++ environment. Swift 6.2.3 and
6.4.1 use the debug-type workaround above; only 6.4.1 uses the native build system.
The Linux 6.4.1 jobs also select the native build system to avoid a crash during
Swift Build planning on the hosted x86_64 runner. These flags do not change the
compiler versions or skip any functional tests.

Release validation uses Swift 6.3.3 from Xcode 26.6 and the `swift:6.3.3`
container so the API gate can build previous releases requiring Swift 6.3.
The Swift 6.1 Checks jobs validate the minimum compiler independently.

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

CI runs automatically for pushes to `main`. To check a pull request, add the
`run-ci` label from the PR sidebar. Results appear in the PR's **Checks** tab.
Opening a PR or pushing new commits to it does not start CI automatically,
even while the label remains attached. Remove and reapply `run-ci` to check the
latest changes. Other labels do not run tests or cancel an active `run-ci` run.

You can also start **Actions → Checks → Run workflow** and select a branch.
These manual branch runs do not appear as PR checks.

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

To compare Foundation's JSONEncoder/JSONDecoder with Codec on the approximately
1 MB `BackendResponse` test fixture, run only the JSON benchmarks:

```sh
swift test -c release --filter PerformanceTests.testBackendJSON
```

All performance tests use the same measurement and output format. Each path is
printed with its name and time ratio relative to the first (baseline) path,
followed by the full path median and a separate median time per operation for
each stage (for example, Data -> object, object -> tree, tree -> model). The ratio is
`path median / baseline median`, so the baseline is 1.000 and lower is better.
The output also labels how many times a path is faster or slower. Foundation's
direct model coding is the baseline for format benchmarks; the dictionary
benchmark uses the dictionary strategy as its baseline.

Each result is the median of 25 individually timed operations, with rotating
execution order. Fixture construction, correctness checks and warm-up are outside
the measurements. Complete paths are timed together rather than adding stage medians. Stages are
also timed independently using prepared intermediate inputs; their setup is
outside those stage measurements. Stage medians need not sum to the full path
median. There are no speed assertions; use Release without coverage
for useful timings.

The JSON and plist benchmarks use `PortablePayload` with 720 mixed records,
targeting approximately 15 ms for direct Foundation JSON coding in local Release
measurements. The workload is fixed; actual times depend on hardware, toolchain
and format. URL and Data fields have explicit StringURL and Base64Data
representations shared by all encoders. Every format path runs completely from model to Data or from Data to
model.
The BackendResponse JSON benchmarks compare direct JSONEncoder/JSONDecoder with
Enigma plus JSONEncoder/JSONDecoder, Enigma plus Codec's Data overload,
Enigma plus Codec's String overload (including UTF-8 conversion), and Enigma's
Foundation object bridge plus JSONSerialization. Intermediate trees, strings
and Foundation objects are constructed inside the timed operations. Encoding in
these BackendResponse benchmarks uses sorted keys throughout.

Build documentation with Swift 6.2.3 or newer and Xcode's documentation compiler
so links to the generic Unix date strategies resolve. Set `enigmatic_symbols`
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
