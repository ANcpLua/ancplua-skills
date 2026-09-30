---
name: mstestlean
description: LeanTest.MSTest tests for Lean-verified .NET code. Use when a Lean counterexample or claim needs an MSTest test at the owner boundary, or when writing or reviewing LeanTest.MSTest tests.
argument-hint: "<Lean counterexamples or claims> [test project]"
---

# LeanTest tests for Lean claims

Targets: $ARGUMENTS
If none are listed, take the counterexamples and claims of the lean-verify campaign in progress.

Done when every target has a test at the owner boundary that names its Lean declaration and claim in the .trx, every counterexample test fails on the unfixed code for the reason the counterexample states (or the counterexample is reported spurious), and `claim-coverage.cs` exits 0 on the fixed code's .trx for the claims in scope.

This skill is the test half of lean-verify (the `ancplua-lean-verify` plugin). Anchoring, modelling, review, fixes, detection and the final audit follow lean-verify's sections; the tests they run are written here.

## Tools
Tested on .NET SDK 11.0.100-rc.1.26425.128, TFM `net11.0`, MSTest.Sdk 4.4.1 on Microsoft.Testing.Platform 2.4.1, LeanTest.Core, LeanTest.MSTest and LeanTest.DI.DotNetCore 4.15.0.435, and Microsoft.Extensions.DependencyInjection 10.0.12.
- `dotnet run ${CLAUDE_SKILL_DIR}/scripts/claim-coverage.cs -- <results.trx>... --claims <Namespace.Spec.Claim>...`
  Maps each test's `[TestTag]` to the claims, as JSON with the test's outcome and scenario ids. Exit 0 every claim has a passed test, 2 usage, 5 no LeanTest markers in any result (not evidence), 6 a claim uncovered or not passed, or a tag naming no listed claim (stale).

## LeanTest
The packages ship no README and no repository URL; the API reference is the XML docs in each package's `lib/net10.0/`. What those docs leave out:
- Pin LeanTest.Core, LeanTest.MSTest and LeanTest.DI.DotNetCore to one exact version: the MSTest and DI packages require Core only as a minimum.
- Build one `ContextBuilder` per test: `new ContextBuilder(new IocContainer(provider))`. `ContextBuilderFactory` keeps its container and last builder in static fields, which parallel tests share.
- `WithData(x)` then `Build()` hands `x` to every registered `IStateHandler<T>` (owned state) or `IMockForData<T>` (an external dependency; `TypedData<T>` is a base class for it). Data no handler takes fails with "No state-handler or mock-for-data was found".
- `RegisterAttributes(TestContext, Assembly)` in `[TestInitialize]` writes `TestScenarioId = ###---<id>---###` and `TestTag = ###---<tag>---###` into the test's StdOut, which the .trx keeps. The attributes alone leave no trace.
- `ExceptionAssert.DoesNotThrow(Async)` reports the exception's type and drops its message. When the message carries the reason, as a timeout naming what stayed open does, let the exception propagate.
- `MultiAssert.Aggregate` runs every assertion and fails once with all their messages: one assertion per conjunct of a claim.

## 1. Map
Each counterexample is a Lean run that breaks a Spec claim.
- `[TestScenarioId]` is the fully qualified Lean declaration that exhibits the run (`SpanCapture.preFix_staleRelease_strands`); `[TestTag]` is the claim it breaks (`SpanCapture.Spec.OpenSpansStopIntoTheirCapture`). A non-vacuity witness gets a test the same way, tagged with its claim.
- The initial state is data: `WithData`, applied by the `IStateHandler<T>` implementations the test's container registers. `State.init` declares none.
- The steps are calls on the owner from `GetInstance<T>()`, in the run's order, each commented with the model actions it performs. Actions the model splits inside one call stay that one call; a run that needs an interleaving inside a call belongs to lean-verify §3's forced interleavings.
- The assertions negate the claim's observable conjuncts, read from the Spec, each commented with its conjunct.

Done when every action of the run sits in a commented call and every assertion names its conjunct.

## 2. Compose
The container holds the owner's production composition, registered by the test project, with only external dependencies replaced by `IMockForData<T>`. Production code gains nothing for the test (lean-verify §3). Dispose the `ServiceProvider` in `[TestCleanup]`.

## 3. Reproduce
Run the test on the unfixed code: the pre-fix commit, or, when that is gone, the pre-fix behaviour the broken model documents, applied in a worktree and restored afterwards. It must fail, and the failure must name the state the run reaches; otherwise report the counterexample spurious (lean-verify §5). Then run it on the fixed code, where it passes.

`dotnet test --project <tests.csproj> --filter "FullyQualifiedName~<Class>" --report-trx --report-trx-filename <name>.trx --results-directory <dir> --minimum-expected-tests <n>`

## 4. Cover
Run `claim-coverage.cs` on the fixed code's .trx with every claim of the Spec in scope. An uncovered claim gets a test from its non-vacuity witness, or a line in the report saying why not. A stale tag means a claim was renamed or removed: retag the test.

## Report
Per target: scenario id, claim, test, the unfixed failure message, the fixed pass, and rerun commands. The claim-coverage JSON. Counterexamples reported spurious. These tests are lean-verify §6's detection suite; its mutation runs pass `--minimum-expected-tests`.
