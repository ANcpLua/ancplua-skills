---
name: mstest-extensions
description: Write, review, troubleshoot, or migrate MSTest tests on MTP. Use when writing tests or assertions, DataRow or DynamicData cases, lifecycle and TestContext, timeouts, parallel isolation, custom assertions or attributes, or MTP runner and filter problems. Not for LeanTest.MSTest claims (mstestlean) or suite pruning (test-audit).
---

# MSTest tests

Write the smallest test that protects public behavior, using official docs for the installed MSTest version; ordinary tests need no extension. Read [workflow](references/workflow.md) for each step's full rules, routing table and done criteria.

1. **Contract.** Name the observable behavior, caller, resource owner, installed MSTest/MTP versions and test entrypoint. Keep packages, runner, extensions profile and coverage provider unless asked to change them. Explanations and reviews stay read-only.
2. **Docs.** Pick one page from [sources](references/sources.md); cite it; check its "starting with MSTest x.y" notes against the installed version; state gaps instead of guessing a signature.
3. **Implement** the smallest slice through the real public entrypoint; for a non-ordinary case read:
   - [data](references/data-and-scenarios.md): DataRow, DynamicData, TestDataRow, combinatorial and custom sources.
   - [lifecycle](references/lifecycle-and-resources.md): fixtures, TestContext, timeouts, cancellation, parallel isolation.
   - [assertions](references/assertions-and-execution.md): exceptions, Assert.That extensions, conditions, retry, custom attributes.
4. **Verify.** List the new cases, check names and counts, run the focused tests through the repository's entrypoint; bug fixes fail first. Skipped, inconclusive or zero-test results are not passes. Report commands, counts and untested paths. For filters, extensions, exit codes, coverage or flakiness read [runner](references/runner-and-verification.md).
