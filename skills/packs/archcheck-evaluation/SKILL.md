---
name: archcheck-evaluation
description: Develop and evaluate ArchCheck analysis - static rules SR1-SR6, runtime rules RT1-RT3, ownership inference, SARIF interpretation, finding aggregation, coverage. Use when changing a rule, analyzing repository or trace evidence, or making precision/recall or empirical result claims.
---

# ArchCheck analysis and evaluation

Paths are relative to `ArchCheck/`. Before running or changing targets, read the `fallout-build` skill (its `references/archcheck.md`) for commands, input restrictions, and artifact lifecycle. This skill owns analysis semantics and evaluation evidence.

1. State the input, research question or changed rule, analysis date, and scope.
2. Inspect ownership before interpreting violations.
3. Run the permitted Fallout target; inspect that fresh run's `artifacts/runs/<name>/`.
4. Verify `infer`, `restore`, `build`, and `report` outcomes individually. Fallout may finish successfully when a repository build failed: its report then has `status: failed` and `counts: null`. Partial findings are observations from an incomplete run, not zero findings or a passing evaluation.
5. Even `status: completed` requires a coverage check.
6. Finish with traceable findings, explicit coverage and failures, and clearly separated observations, inferences, and unresolved claims. Regenerate derived tables from the verified run; editing generated counts cannot repair an analysis.

Read when needed:

- [sources.md](references/sources.md): source of truth per area, before tracing or changing semantics.
- [evidence.md](references/evidence.md): steps 1-5 detail: metadata limits, inference order, coverage, run artifacts.
- [interpretation.md](references/interpretation.md): before interpreting SR1-SR6 results or computing precision/recall.
- [runtime.md](references/runtime.md): RT1-RT3 trace evaluation, and verification after changing semantics.
