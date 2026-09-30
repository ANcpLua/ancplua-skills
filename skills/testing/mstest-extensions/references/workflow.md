# Workflow details

Use official documentation for the installed MSTest version and the smallest test
that protects the public behavior. Make a capability reusable when it hides real
complexity; ordinary tests do not need an extension.

## 1. Establish the contract and installed API

Identify the observable behavior, the caller that exercises it, and who owns
resources. Read project files, `global.json` (`msbuild-sdks` → `MSTest.Sdk`,
`test.runner`), central package versions, target frameworks, `testconfig.json` or
`.runsettings`, and existing test instructions. Preserve the packages, the runner
(MTP or VSTest), the MSTest.Sdk extensions profile, and the coverage provider unless
changing them is part of the request. Using a new assertion alone is not a request
to migrate the runner or the SDK.

For an explanation or review, stay read-only. For implementation, name the smallest
behavior case to add. Done when the contract, the MSTest and MTP versions, and the
test entrypoint are explicit—not when a new abstraction has been chosen.

## 2. Resolve only the documentation needed

Select the nearest topic in [Documentation routes](sources.md) before choosing
APIs or commands. Start with one page and follow another only to resolve a specific
gap. Many features carry a "starting with MSTest x.y" or "introduced in MTP x.y"
note, and some pages describe features that are still in preview; compare each note
with the installed version before using the feature.

When documentation conflicts with the installed package, check the version-matched
API reference or source. State unresolved gaps instead of guessing a signature or
upgrading to make an example fit. Cite the source used; compile against the installed
package before calling an example verified. Done when the needed API and its version
limits are clear, or the missing evidence is explicit.

## 3. Implement the smallest observable slice

For an ordinary test, assertion, or migration, apply the documented pattern
directly. Load a deeper reference only when its branch applies.

| Need | Start with | Read before implementing |
| --- | --- | --- |
| A few related input/output examples | `[DataRow]` | [Data and scenarios](data-and-scenarios.md) |
| Computed or typed cases, per-case metadata | `[DynamicData]` returning value tuples or `TestDataRow<T>` | [Data and scenarios](data-and-scenarios.md) |
| Independent axes, every combination meaningful | `[CombinatorialData]` | [Data and scenarios](data-and-scenarios.md) |
| A reusable custom data source | An attribute implementing `ITestDataSource` | [Data and scenarios](data-and-scenarios.md) |
| Owned async resources or shared setup | Constructor or `TestInitialize` with `IAsyncDisposable`, class or assembly fixtures | [Lifecycle and resources](lifecycle-and-resources.md) |
| Timeouts, cancellation, suspension | `[Timeout]` with cooperative cancellation and `TestContext.CancellationToken` | [Lifecycle and resources](lifecycle-and-resources.md) |
| Process-wide state under parallel runs | Per-test isolation, else `[DoNotParallelize]` | [Lifecycle and resources](lifecycle-and-resources.md) |
| Expected exceptions | `Assert.Throws`/`Assert.ThrowsExactly` and their async forms | [Assertions and execution](assertions-and-execution.md) |
| A repeated domain expectation | Existing `Assert` methods, then an extension reached through `Assert.That` | [Assertions and execution](assertions-and-execution.md) |
| Thread affinity, platform conditions, retry, custom test attributes | `STATestMethod`, condition attributes, `Retry`, a `TestMethodAttribute` subclass | [Assertions and execution](assertions-and-execution.md) |
| Architecture rules as tests for a declared style | `[Monolith]`, `[Microservices]` or `[DistributedMonolith]` with a rule family | [Architecture attributes](architecture-attribute.md) |
| Discovery, filtering, extensions, exit codes, coverage, flakiness | The configured runner and repository wrapper | [Runner and verification](runner-and-verification.md) |

Use the relevant branch only. Keep scenario descriptions immutable and create
mutable resources per execution. Let the framework own fixture lifetimes it creates;
let the test own resources it constructs. With in-assembly parallelization enabled,
shared mutable resources need an explicit isolation policy.

Exercise the real public entrypoint: CLI and build contracts through their actual
entrypoints, not a helper that skips the parsing or wiring the test claims to
protect. A controllable stream is useful for read fragmentation, faults, and
suspension; an in-process local server is useful for wire-level HTTP contracts. Name
these by their behavior, not all as "mocks." Do not assert private call sequences
unless the interaction is the public contract.

Preserve diagnostics and ownership that belong to the contract: warnings must survive
every path to the caller, and a stream the code under test opens is disposed by that
code while a caller-supplied stream stays the caller's. Done when the test
distinguishes the intended result from a plausible broken implementation.

## 4. Verify discovery, behavior, and scope

List the new cases, check names and counts, then run the focused tests through the
repository's normal entrypoint. For a bug fix, establish the failing case first;
existing correct behavior can pass a newly added contract test. Check a custom
assertion's rejecting path as well as its accepting path.

A gate passes only on a measured result: skipped, inconclusive, zero-test, missing
input, and disabled-threshold outcomes are not passes, and the exit status and summary
must describe the same evaluated run. Keep retries out of flakiness measurements.
Report executed commands, observed counts, and untested paths separately; passing
tests and coverage percentages are not proof of correctness. Keep build commands in
project instructions rather than copying one repository's wrapper into this skill.
