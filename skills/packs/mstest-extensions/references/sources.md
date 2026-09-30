# Documentation routes

Choose one page for the current task, not every link in its row. Pages live under
`https://learn.microsoft.com/dotnet/core/testing/` unless a row says otherwise; fetch
them with the Microsoft Learn tools when available, otherwise over HTTPS. API
reference pages accept a version view such as `?view=mstest-net-4.4`; match it to the
installed `MSTest.TestFramework` version when a signature matters.

Read the installed version first: `global.json` → `msbuild-sdks` → `MSTest.Sdk`, or the
`MSTest`/`MSTest.TestFramework` package pin. The docs flag features by the version that
introduced them, and some pages describe features that are still in preview. Only the
latest released MSTest is supported; its [changelog](https://github.com/microsoft/testfx/blob/main/docs/Changelog.md)
and the [testfx source](https://github.com/microsoft/testfx) settle behavior the docs
leave open. If a page is unavailable, use installed API or source evidence and
disclose what remains unverified.

## MSTest topics

| Task | Page |
| --- | --- |
| Create a project | `unit-testing-mstest-getting-started` |
| MSTest.Sdk, extension profiles, VSTest opt-out | `unit-testing-mstest-sdk` |
| Test structure, attribute quick reference | `unit-testing-mstest-writing-tests` |
| Assertions and custom assertions | `unit-testing-mstest-writing-tests-assertions` |
| DataRow, DynamicData, combinatorial data, unfolding | `unit-testing-mstest-writing-tests-data-driven` |
| Assembly, class, test, and global fixtures | `unit-testing-mstest-writing-tests-lifecycle` |
| Threading, parallelization, timeouts, retry, conditions, dependencies | `unit-testing-mstest-writing-tests-controlling-execution` |
| Categories, properties, owners, work items | `unit-testing-mstest-writing-tests-organizing` |
| TestContext and its cancellation token | `unit-testing-mstest-writing-tests-testcontext` |
| Deployment items | `unit-testing-mstest-writing-tests-deployment-items` |
| `testconfig.json` and `.runsettings` entries | `unit-testing-mstest-configure` |
| Analyzer rules (`MSTESTnnnn`) | `mstest-analyzers/overview`, one rule at `mstest-analyzers/mstest00nn` |
| Running MSTest, filters, runsettings | `unit-testing-mstest-running-tests`, `selective-unit-tests?pivots=mstest` |
| `dotnet test` in MTP mode | `https://learn.microsoft.com/dotnet/core/tools/dotnet-test-mtp`, `unit-testing-with-dotnet-test` |
| MTP options, exit codes, configuration | `microsoft-testing-platform-cli-options`, `microsoft-testing-platform-troubleshooting`, `microsoft-testing-platform-config` |
| MTP extensions: reports, coverage, dumps, retry | `microsoft-testing-platform-features`, then `-test-reports`, `-code-coverage`, `-crash-hang-dumps`, `-retry` |
| Migration | `unit-testing-mstest-migration-v3-v4`, `unit-testing-mstest-migration-from-v1-to-v3`, `migrating-vstest-microsoft-testing-platform` |
| Writing an MTP extension | `microsoft-testing-platform-architecture-extensions` |
