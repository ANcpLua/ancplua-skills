---
name: mutation-tester
description: Stryker-style mutation testing: kill surviving mutants with targeted tests and gate on a mutation-score baseline. Use when asked for mutation testing, a mutation score, Stryker, "how good are my tests really", test gaps beyond line coverage, or proof maintenance did not weaken the suite. Not for Lean proofs (lean-verify) or test pruning (test-audit).
---

# Mutation testing

Line coverage says the code *ran*; only a killed mutant proves a test would *fail* if the code broke. Two modes: **hunting** (first run on a target: raise the score by killing real gaps) and **baseline gating** (every later run: hold the recorded score and chase only what moved). Hunting ends; gating never does.

- [references/setup.md](references/setup.md): stack detection, Stryker commands, manual-probing fallback. Read before running.
- [references/baseline-gate.md](references/baseline-gate.md): regression, new-code and stop-hunting rules. Read on every later run.
- [references/ship.md](references/ship.md): PR shape and final report. Read before shipping.

## Steps

1. **Run** Stryker in an isolated git worktree, never the main checkout.
2. **Judge** each survivor, a candidate, not automatically a finding: equivalent mutant (no observable behavior change: note it, no action), dead code (route to a dead-code routine), or a real test gap.
3. **Kill** each real gap with the smallest test asserting user-visible behavior, never one that mirrors implementation text. Apply the mutant, confirm the new test fails, revert, confirm the suite is green (apply-fail-revert-verified). A test never seen failing proves nothing.
4. **Prioritize** by blast radius: verdict/gating/money/merge logic first, formatting cosmetics last.
5. **Record** the mutation score per target when a run finishes, with the survivors deliberately left and why.
6. **Ship** only with build + full tests green.
