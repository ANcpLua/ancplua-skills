# Workflow details

Use official documentation for the installed API and the smallest test that
protects the public behavior. Make a capability reusable when it hides real
complexity; ordinary tests do not need an extension.

## 1. Establish the contract and installed API

Identify the observable behavior, the caller that exercises it, and who owns
resources. Read project files, central package versions, target frameworks,
`global.json`, and existing test instructions. Preserve the packages, runner,
and coverage provider unless changing them is part of the request. Using an
assertion or mocking package alone is not a request to migrate the test runner.

For an explanation or review, stay read-only. For implementation, name the
smallest behavior case to add. Done when the contract, version, and test entrypoint
are explicit—not when a new abstraction has been chosen.

## 2. Resolve only the documentation needed

Select the nearest topic in [Documentation routes](sources.md) before
choosing APIs or commands. Start with one page. Prefer a corresponding page from
a local mirror supplied by the user or project; otherwise fetch the official
Markdown page. Reuse documentation already in context unless it needs refreshing.
Follow another page only to resolve a specific gap; the route file describes the
index fallback and URL handling.

When documentation conflicts with itself or the installed package, check
version-matched source or local API evidence. State unresolved gaps instead of
guessing a signature or upgrading to make an example fit. Cite the source used;
compile against the installed package before calling an API example verified.

Done when the needed API and its version limits are clear, or the missing evidence
is explicit. A documentation lookup is not a runtime check.

## 3. Implement the smallest observable slice

For an ordinary test, assertion, or migration, apply the relevant documented
pattern directly. Load a deeper reference only when its branch below applies.

| Need | Start with | Read before implementing |
| --- | --- | --- |
| A few related input/output examples | `[Arguments]` or a method data source | [Data and scenarios](data-and-scenarios.md) |
| Independent axes, every combination meaningful | `[MatrixDataSource]` | [Data and scenarios](data-and-scenarios.md) |
| Reusable typed scenarios or fresh per-case objects | `DataSourceGeneratorAttribute<T>` | [Data and scenarios](data-and-scenarios.md) |
| Owned async resources or shared setup | `ClassDataSource<T>` and lifecycle interfaces | [Lifecycle and resources](lifecycle-and-resources.md) |
| Controlled suspension or cancellation | A releasable dependency and explicit operation ownership | [Lifecycle and resources](lifecycle-and-resources.md) |
| Outcome-aware diagnostics | A teardown hook or event receiver | [Lifecycle and resources](lifecycle-and-resources.md) |
| A repeated domain expectation | Existing assertions, then a generated assertion | [Assertions and execution](assertions-and-execution.md) |
| A real scheduling/thread-affinity requirement | A test executor | [Assertions and execution](assertions-and-execution.md) |
| Discovery, filtering, coverage, or flakiness measurement | The configured runner and repository wrapper | [Runner and verification](runner-and-verification.md) |

Use the relevant branch only. A data-source “generator” produces test data; it
does not require writing a Roslyn incremental generator. TUnit supplies the
compile-time wiring. An additional assertion or mocking package needs a concrete
capability gap, not a preference for more fluent syntax.

Keep scenario descriptions immutable and create mutable resources per execution.
Let the framework own injected fixture lifetimes; let the test own resources it
constructs. With the TUnit runner, tests run in parallel by default, so shared
mutable resources need an explicit isolation policy. Observe TUnit assertions,
normally with `await`; this alone does not require changing a synchronous action
under test.

Exercise the real public entrypoint. A controllable stream is useful for read
fragmentation, faults, and suspension; an in-process local server is useful for
wire-level HTTP contracts. Name these by their behavior, not all as “mocks.”
Do not assert private call sequences unless the interaction is the public contract.

For suspension or cancellation tests, read the lifecycle branch before designing
the handshake and cleanup. Prove successful resumption separately from
cancellation; observe the original operation before disposing its dependencies,
including on a failed assertion. A timeout limits waiting, not arbitrary work.

Done when the test distinguishes the intended result from a plausible broken
implementation, including diagnostics and ownership that belong to its contract.

## 4. Verify discovery, behavior, and scope

Discover the new cases, check names and counts, then execute the focused tests
through the repository's normal entrypoint. For a bug fix, establish the failing
case first. Existing correct behavior can pass a newly added contract test.
Check a custom assertion's rejecting path as well as its accepting path.

Keep retries out of flakiness measurements. Report executed commands, observed
counts, and untested paths separately; passing tests and coverage percentages
are not proof of correctness. Keep build commands in project instructions rather
than copying one repository's wrapper into this skill.
