# Documentation routes

Choose one page for the current task, not every link in its row. With a local
documentation mirror, map the URL's `docs/...md` path beneath that mirror's root.
Read its provenance/version note; a refresh label does not prove that each page
matches the installed package. Keep machine-specific mirror paths in project
instructions, outside this portable skill.

For an unlisted topic or missing route, search the local mirror's index or file
names; otherwise fetch [the official index](https://tunit.dev/llms.txt) and select
the matching page. Avoid loading `llms-full.txt` or crawling the whole site.
Follow related links only for unresolved details. For an official HTML docs URL,
remove the trailing slash and append `.md` before any fragment; keep existing
`.md` paths unchanged and resolve relative links against the source page's URL.
If a page is unavailable, use available local docs or installed API/source evidence
and disclose what remains unverified.

## TUnit topics

| Task | Official documentation |
| --- | --- |
| Create or configure a project | [Installation](https://tunit.dev/docs/getting-started/installation.md) |
| Write a basic test | [First test](https://tunit.dev/docs/getting-started/writing-your-first-test.md) |
| Assertions, exceptions, composition | [Assertions](https://tunit.dev/docs/assertions/getting-started.md) |
| Parameterized tests | [Arguments](https://tunit.dev/docs/writing-tests/arguments.md), [method data](https://tunit.dev/docs/writing-tests/method-data-source.md), or [matrix data](https://tunit.dev/docs/writing-tests/matrix-tests.md) |
| Setup, teardown, hooks | [Lifecycle](https://tunit.dev/docs/writing-tests/lifecycle.md) or [hooks](https://tunit.dev/docs/writing-tests/hooks.md) |
| Fixtures, sharing, injection | [Class data sources](https://tunit.dev/docs/writing-tests/class-data-source.md) or [dependency injection](https://tunit.dev/docs/writing-tests/dependency-injection.md) |
| Concurrency and test dependencies | [Parallelism](https://tunit.dev/docs/execution/parallelism.md) or [ordering](https://tunit.dev/docs/writing-tests/ordering.md) |
| Running and filtering | [Running tests](https://tunit.dev/docs/getting-started/running-your-tests.md) or [filters](https://tunit.dev/docs/execution/test-filters.md) |
| Migration | [xUnit](https://tunit.dev/docs/migration/xunit.md), [NUnit](https://tunit.dev/docs/migration/nunit.md), or [MSTest](https://tunit.dev/docs/migration/mstest.md), matching the existing framework |
| Mocking | [TUnit.Mocks](https://tunit.dev/docs/writing-tests/mocking.md) |
| Aspire integration | [Aspire](https://tunit.dev/docs/examples/aspire.md) |
| ASP.NET Core integration | [ASP.NET Core](https://tunit.dev/docs/examples/aspnet.md) |
| Browser tests | [Playwright](https://tunit.dev/docs/examples/playwright.md) |
| Container fixtures | [ASP.NET Core examples](https://tunit.dev/docs/examples/aspnet.md), section "With Testcontainers" |
| AOT, trimming, discovery modes | [AOT](https://tunit.dev/docs/writing-tests/aot.md) or [engine modes](https://tunit.dev/docs/execution/engine-modes.md) |
| Domain assertions, including custom messages and async checks | [Generated assertions](https://tunit.dev/docs/assertions/extensibility/source-generator-assertions.md); use [manual assertions](https://tunit.dev/docs/assertions/extensibility/custom-assertions.md) for capabilities generation cannot express |
| Custom data sources | [Data source generators](https://tunit.dev/docs/extending/data-source-generators.md) |
| Scenario names | [Argument formatters](https://tunit.dev/docs/extending/argument-formatters.md) |
| Executors and extension interfaces | [Extension points](https://tunit.dev/docs/extending/extension-points.md) |
| Event receivers | [Event subscribing](https://tunit.dev/docs/writing-tests/event-subscribing.md) |
| Test context and metadata | [Test context](https://tunit.dev/docs/writing-tests/test-context.md) |
| Logs, failure artifacts, tracing | [Logging](https://tunit.dev/docs/extending/logging.md), [artifacts](https://tunit.dev/docs/writing-tests/artifacts.md), or [OpenTelemetry](https://tunit.dev/docs/examples/opentelemetry.md) |
| Cancellation | [Cancelling a test](https://tunit.dev/docs/execution/cancellation.md) |
| Discovery, build, execution failures | [Troubleshooting](https://tunit.dev/docs/troubleshooting.md) |

## Runner, providers, and source

| Question | Primary reference |
| --- | --- |
| Implementations and version history | [TUnit source](https://github.com/thomhurst/TUnit) |
| Runner modes and flags | [Microsoft dotnet test](https://learn.microsoft.com/en-us/dotnet/core/testing/unit-testing-with-dotnet-test) |
| Registered options and runner failures | [MTP diagnostics](https://learn.microsoft.com/en-us/dotnet/core/testing/microsoft-testing-platform-troubleshooting) |
| Native Coverlet integration | [coverlet.MTP](https://github.com/coverlet-coverage/coverlet/blob/master/Documentation/Coverlet.MTP.Integration.md) |
| Microsoft coverage integration | [CodeCoverage extension](https://learn.microsoft.com/en-us/dotnet/core/testing/microsoft-testing-platform-extensions-code-coverage) |

For runner or provider conflicts, consult the installed tool's help and the
provider-specific source. A blanket statement about legacy Coverlet packages
does not establish whether a separately installed MTP provider is supported.

## Provenance and validation limits

Routing adapted from the official TUnit skill at **v1.68.4**; see
[upstream attribution and license](../UPSTREAM-NOTICE.md). Documentation compared
with a local mirror labelled v1.68.4 on 2026-09-18. Both online and mirrored docs
can differ from a consumer's installed API.

The executable examples still target **TUnit 1.67.0 / .NET 10**. The routing merge
did not revalidate those examples on 1.68 or change consumer versions.

Use documentation to locate a capability, the installed package/source to
confirm its signature, and a focused compile/discovery/run to verify usage.
Keep examples and runtime validation distinct from documentation claims.
