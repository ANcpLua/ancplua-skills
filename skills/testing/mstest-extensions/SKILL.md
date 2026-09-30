---
name: mstest-extensions
description: Write, review, fix, or migrate MSTest tests on MTP. Use when writing tests or assertions, data-driven cases, lifecycle and TestContext, timeouts, parallel isolation, custom attributes, Monolith/Microservices/DistributedMonolith architecture attributes, or MTP runner problems. Not for LeanTest.MSTest (mstestlean) or pruning (test-audit).
---

# MSTest tests

Write the smallest test that protects public behavior, from official docs for the installed MSTest version; ordinary tests need no extension. [Workflow](references/workflow.md) holds each step's full rules, routing and done criteria.

1. **Contract.** Name the observable behavior, caller, resource owner, installed MSTest/MTP versions and test entrypoint. Keep packages, runner, extension profile and coverage provider; reviews stay read-only.
2. **Docs.** Cite one page from [sources](references/sources.md); check its "starting with MSTest x.y" notes against the installed version, state gaps instead of guessing a signature.
3. **Implement** the smallest slice through the real entrypoint; before non-ordinary cases read:
   - [data](references/data-and-scenarios.md): DataRow, DynamicData, TestDataRow, custom sources.
   - [lifecycle](references/lifecycle-and-resources.md): fixtures, TestContext, timeouts, parallel isolation.
   - [assertions](references/assertions-and-execution.md): exceptions, Assert.That extensions, conditions, retry, custom attributes.
   - [architecture](references/architecture-attribute.md): style attributes over ArchCheck rule families.
4. **Verify.** List new cases, check names and counts, run focused tests via the repository's entrypoint; bug fixes fail first. Skipped, inconclusive or zero-test results are not passes; report commands, counts and untested paths. For filters, exit codes, coverage or flakiness read [runner](references/runner-and-verification.md).
