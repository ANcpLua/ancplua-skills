# Runner and verification

Use the repository's entrypoint (a build target or wrapper) for routine runs; use
direct runner commands for discovery and focused diagnosis.

## Runner mode

MSTest.Sdk runs on Microsoft.Testing.Platform (MTP) by default; `UseVSTest=true`
switches to VSTest, and in MSTest 4 the SDK no longer adds `Microsoft.NET.Test.Sdk`
under MTP. With the .NET 10 SDK, `global.json` `{"test": {"runner": "Microsoft.Testing.Platform"}}`
selects the MTP mode of `dotnet test`; then every test project must use MTP, and MTP
options go straight to `dotnet test`. VSTest mode has different argument rules.
A test project is also an executable: `dotnet run --project <proj> -- <options>`.

## Discovery and filters

- `dotnet test --project <proj> --list-tests` lists cases without running them
  (`json` output from MTP 2.3). Check names and counts after adding cases; folded data
  cases show as one node.
- `--filter` takes MSTest expressions, for example
  `"FullyQualifiedName~ParserTests|TestCategory=Integration"`; see the MSTest
  selective-tests page for operators.
- `--minimum-expected-tests <n>` fails the run (exit code 9) when a filter selects
  fewer tests, so an empty selection cannot pass silently.

## Exit codes

5 invalid or unrecognized option (often an extension that is not registered),
8 zero tests ran, 9 minimum expected tests not met, 13 stopped at
`--maximum-failed-tests`. Suppress 8 with `--ignore-exit-code 8` only on purpose.
A wrapper may map the child's exit code; read the child's code in its log.

## Extensions

MTP core has no report, coverage, dump, or retry options; each comes from an extension
package. MSTest.Sdk's `TestingExtensionsProfile`: `Default` (code coverage, TRX, and
from MSTest.Sdk 4.3 the Azure DevOps report plus an experimental GitHub Actions report), `AllMicrosoft` (adds crash
and hang dumps, Fakes, hot reload, HTML report, retry), or `None`. Run `--info` or
`--help` to see registered options. In a solution mixing frameworks or extensions,
route options per project with a conditioned `TestingPlatformCommandLineArguments`.

Common options: `--report-trx`, `--coverage`, `--results-directory`, `--crashdump`,
`--hangdump --hangdump-timeout 10m`, and
`--diagnostic --diagnostic-verbosity Trace --diagnostic-output-directory <dir>`.
From MTP 2.3, `testconfig.json` can carry CLI options; the command line wins. Keep the
repository's coverage provider rather than adding a second one.

## Measure, then claim

- Reproduce flakiness with repeated runs and no retry extension; report retried passes
  separately.
- A coverage or quality gate passes only on a measured result: no data, missing
  inputs, and disabled thresholds are not passes. Combine only reports from the
  intended run; the exit status and the summary must describe the same result.
- Report executed commands, observed counts, and untested paths; passing tests and
  coverage percentages are not proof of correctness.
