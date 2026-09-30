# Verification, fixer fleet and integration (phases 3-5)

## 3. Adversarial verification per cluster

Every cluster gets a verifier whose mandate is to REFUTE it: default not-real, confirmed only when the failure scenario survives an active attempt to break it against the current code. The verifier also reviews the proposed fix, and its `fix_adjustment` OVERRIDES the finder's proposal — the verified fix is what the fixers implement, not the original suggestion.

## 4. Fixer fleet

- **Disjoint file ownership**: every fixer owns an explicit, non-overlapping file set and works in its own isolated git worktree. Work outside the boundary goes into `cross_boundary_notes` handed to the owning fixer — never fixed by trespassing.
- **Two-wave sequencing**: when one fixer's work depends on another's new API, the dependent fixer runs in wave 2, starting from the merged wave-1 state — never from declared-but-unbuilt signatures.
- **Per-fixer gate**: build with 0 warnings plus the full test suite green before the fixer's single commit. One commit per fixer.
- **Conduct rules**: a user rejection of a command is TERMINAL for that exact command — never re-issue it; ask, or propose an alternative. After ONE settings/permissions denial, report the proposed permission rule to the human instead of retrying through a different write mechanism. Allowlist proposals cover only read-only, high-frequency, unambiguous operations, each backed by an observed denial — never writes, deletes, installs, or network sends.

## 5. Integration

A single writer merges all fixer commits, runs full verification (build, suite, and any baselines such as the mutation score against the recorded floor), and delivers per the repo's agreed flow. Nobody else writes to the integration branch.
