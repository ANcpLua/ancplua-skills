---
name: test-audit
description: Audit and prune an existing .NET test suite (MSTest on Microsoft.Testing.Platform) by finding tests that restate the implementation, duplicate stronger tests, or keep test-only production seams alive, then removing or consolidating them with evidence. Use when asked to audit, clean up, prune, dedupe, or consolidate tests, to cut test count against a coverage target, or to judge whether tests earn their keep.
argument-hint: "<area> [target, e.g. remove 20% and keep coverage within 2 points]"
---

# Test audit (.NET, MTP)

Scope and target: $ARGUMENTS

New tests are gated by the authoring rules in CLAUDE.md; this skill sweeps existing ones. Optimize for confidence per maintained line, not for deletion count.

Written against MSTest.Sdk 4.4.1 on Microsoft.Testing.Platform 2.4.1 (API docs: `view=mstest-net-4.4`).

## Done
- A numeric target is the effort bar, not a quota. Keep going until it is met or every remaining candidate has written evidence it should stay; never delete a test that clears the retention bar to reach the number.
- Coverage is a floor. Lines stay covered while assertions disappear, so also require that the remaining suite still kills every mutant the old suite killed in the code the deleted tests exercised.

## Baseline, before any edit
Record the commit, dirty files and `dotnet --version`, then run the full suite once:
`dotnet test <solution or project> --report-trx --coverage --coverage-output-format cobertura --results-directory <dir>`
Keep the executed test count and the `line-rate` and `branch-rate` attributes of the cobertura root. Compare later runs in percentage points, with the same command on the same machine.

Count tests, not attempts: every `[Retry]` attempt is reported (`failed (try 1) MyTest`) while the test counts once; keep the `flaky:` and `retried:` summary lines with the baseline. Record what removes tests from the count without a failure: an `ITestFilter` that returns `Drop` (`[assembly: TestFilterProvider]`), a failed `[DependsOn]` prerequisite, which skips its dependents, and `EnableMSTestSourceGeneration`, under which a class that only inherits `[TestClass]` is never discovered (MSTEST0069).

## Hunt
The build's analyzer warnings name the first candidates: MSTEST0074 to MSTEST0077 (tests that mutate process-global state, the current directory, culture or shared files under parallel execution) and MSTEST0082 (inherited tests that MSTest skips silently because their base class was compiled against another MSTest major version).

Read the whole test and its production owner (entry point, callers, sibling tests, git history) before judging it. Candidates:
- guard-and-return: an early `return` or `Assert.Inconclusive` on the architecture, the `CI` variable or a missing executable, which reports a pass without testing anything (MSTEST0079, MSTEST0080, MSTEST0083);
- hand-rolled isolation where MSTest has an attribute: `[DoNotParallelize]` or ordering by name around one shared resource (`[ResourceLock]`, `[DependsOn]`), temporary directories created and deleted by hand (`TestContext.TestTempDirectory`);
- `[DataRow]` grids that spell out every combination (`CombinatorialData`);
- no assertion, or only "doesn't throw" where a real outcome is observable;
- property round-trips, identity copies, self-comparisons;
- copied inventories: enum members, constants, DI registrations, option names, export lists;
- source or string greps of implementation text;
- mocks verifying the call shape (`Verify(..., Times.Once)`) where the effect itself is observable; mocks that implement the asserted behavior; one mock standing in for different APIs;
- expected values computed by the code under test;
- one scenario replayed at every layer; near-duplicates that should be `[DataRow]`s;
- null-guard tests on internal types;
- tests that only keep test-only seams alive (InternalsVisibleTo-only members, hooks, flags), and production code whose only callers are tests;
- fixtures that supply the ordering, state or receipt the production path should produce;
- negative tests that pass for an unrelated reason (a different guard, a rejection the real path never reaches);
- names that promise more than the test exercises.

## Retention bar
Keep a test when it independently guards a public API, a wire format or serialization (e.g. OTLP payloads), config, migrations, storage, security, AOT or trimming behavior, source-generator output, platform behavior, defaults, observable ordering, or a regression with a credible failure mode. Resembling the implementation isn't enough to delete it: show the contract is guarded elsewhere first. Slow or static isn't a reason either. A retained test that fails on the baseline is a possible product bug; reproduce and report it rather than deleting it.

## Evidence per candidate, before editing
Test name and location; the failure it can actually detect; the stronger remaining test that detects it (by name), or why none is needed; non-test callers of any seam it keeps alive; history (`git log -S`, blame) and why it exists; what deleting it unlocks; risk and the focused validation command.

## Edit shape
One coherent owner-boundary batch per commit. Delete test-only seams together with their tests instead of keeping aliases. Fold near-duplicates into `[DataRow]`s. Turn guard-and-return tests into `[ArchitectureCondition]`, `[CICondition]` or `[ExecutableCondition]`, so that they report skipped; their analyzers carry code fixes. Prefer net-negative production LOC. Don't add replacement tests that restate the same implementation.

## Validate each batch
- Never edit while a build or test run is active in the checkout.
- Focused: `dotnet test --project <proj> --filter "<expr>" --minimum-expected-tests <n>`.
- Mutation check: before deleting, run coverage filtered to just the candidates to get the lines they execute. Afterwards, mutate a sample of those lines with Roslyn, one at a time in a worktree; every mutant the old suite killed must still be killed. Hand contested deletions to the skeptic subagent.
- Full suite with the baseline command; compare executed count and line and branch points.
- `git diff --check`, and report production and test LOC separately (`git diff --numstat`).

## Handoff
Removed categories with counts, seams deleted, retained false positives and why, baseline vs after (tests executed, line %, branch %, mutants killed), commands run, follow-ups. Commit, push or open PRs only when authorized.
