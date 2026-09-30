---
name: tunit-extensions
description: Write, review, troubleshoot, or migrate TUnit, TUnit.Assertions, or TUnit.Mocks tests. Use when writing tests or assertions, data sources and matrices, fixture lifecycles, custom assertions, executors, async isolation, or TUnit/MTP runner problems. Unrelated app edits, mechanical renames, and running unchanged build targets are out of scope.
---

# TUnit testing and extensions

Write the smallest test that protects public behavior, using official docs for the installed API. Ordinary tests need no extension. Read [workflow](references/workflow.md) when a step needs its full rules, routing table or done criteria.

1. **Contract.** Name the observable behavior, its caller, the resource owner, installed versions and test entrypoint. Keep packages, runner and coverage provider unless the request changes them. Explanations and reviews stay read-only.
2. **Docs.** Pick one page from [sources](references/sources.md); cite it; state gaps instead of guessing a signature.
3. **Implement** the smallest slice through the real public entrypoint. Before a non-ordinary case, read its reference:
   - [data](references/data-and-scenarios.md): arguments, method sources, matrices, typed scenario sources.
   - [lifecycle](references/lifecycle-and-resources.md): fixtures, shared setup, suspension, cancellation, failure diagnostics.
   - [assertions](references/assertions-and-execution.md): repeated domain expectations, test executors.
4. **Verify.** Discover the new cases, check names and counts, run the focused tests through the repository's entrypoint; a bug fix fails first. Report commands, counts and untested paths. For discovery, filters, coverage or flakiness, read [runner](references/runner-and-verification.md).
