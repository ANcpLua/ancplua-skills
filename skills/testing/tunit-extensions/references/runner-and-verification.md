# Runner and verification

Determine the SDK, `global.json` test runner, installed TUnit/MTP versions, and
coverage provider. A target framework alone does not identify the runner mode.
Use project instructions for exact commands; prefer the repository's existing
wrapper for routine verification and direct runner diagnostics for gaps.

Discover before executing generated cases. Check the actual runner's `--help`
and `--info` before borrowing flags from another version. Native MTP `dotnet test`
and legacy VSTest integration have different argument forwarding. TUnit uses
`--treenode-filter`, not VSTest's `--filter` expression; a `--` separator is not
universal. Preserve quoted filter arguments across wrapper boundaries;
response-file and MSBuild-property support is mode-sensitive.

C# discovery normally uses source generation; reflection mode also exists and
is the documented default for F# and VB.NET. Check the engine-mode documentation
and installed configuration when changing discovery, language, or Native AOT.

Coverage is a provider choice. Legacy `coverlet.collector`/`coverlet.msbuild` are
not the native MTP integration; `coverlet.MTP` is a separate supported provider.
Microsoft's CodeCoverage extension is another option. Keep the existing provider
unless migration is requested. Use its actual flags and filters, and collect
reports into a fresh run directory; do not mix previous measurements. Keep
coverage opt-in for ordinary fast tests.

For an isolation investigation, compare the same build and case selection alone,
in a sequential suite, and in a bounded parallel suite. Vary culture or timezone
separately. Disable retries at every applicable scope and avoid fail-fast/error
limits that truncate observations. Repeat is a measurement, not a fix.

Finite passing repetitions do not establish determinism. Differences are evidence
to investigate, not proof of one particular cause. State and justify a statistical
model's assumptions before using it to quantify flakiness; shared-state runs do
not establish trial independence or a stable failure probability.
TRX duration does not isolate setup cost. Measure setup boundaries separately
when that is the question. Check exit status and nonzero discovery count as well
as reported passes. Keep coverage percentages separate from assertion quality.

Sources: [dotnet test modes](https://learn.microsoft.com/en-us/dotnet/core/testing/unit-testing-with-dotnet-test),
[MTP diagnostics](https://learn.microsoft.com/en-us/dotnet/core/testing/microsoft-testing-platform-troubleshooting),
[Coverlet MTP](https://github.com/coverlet-coverage/coverlet/blob/master/Documentation/Coverlet.MTP.Integration.md),
[Microsoft coverage](https://learn.microsoft.com/en-us/dotnet/core/testing/microsoft-testing-platform-extensions-code-coverage).
