---
name: maintenance-run
description: Procedure for one autonomous maintenance run - parallel finders, root-cause dedupe, adversarial verification, fixer fleet, single-writer merge, hard termination rule. Not a scheduler; /loop, /schedule or Workflow repeat it. Use when asked for a repo health pass, "find and fix everything", a multi-agent bug-hunting sweep, or when the loop should stop.
---

Run find-verify-fix-integrate as one routine. Findings need repros, fixes need adversarial review before landing, and without a termination condition the loop manufactures its own work.

1. **Find** (read [references/finding.md](references/finding.md) first): read-only finders in parallel, one per dimension, every finding with evidence.
2. **Dedupe by root cause BEFORE verification**: `scripts/findings.py dedupe`, then an arbiter works its `ambiguous` list.
3. **Verify** (read [references/fixing.md](references/fixing.md) first): a verifier tries to REFUTE each cluster; its `fix_adjustment` overrides the finder's fix.
4. **Fix**: disjoint file ownership, one worktree and one gated commit per fixer, dependents in wave 2.
5. **Integrate**: one writer merges, verifies fully with baselines, delivers per the repo's flow.
6. **Report** (read [references/reporting.md](references/reporting.md) first) the run and its findings-curve datapoint.
7. **Open the next run** with `/code-review` on THIS run's diff.
8. **Finish** with the run report, updated findings curve, and an explicit continue-or-terminate verdict under the rule below.

## The termination rule (hard rule, not guidance)

Track the findings curve and the self-introduced share across runs. When most of a run's findings are regressions of the previous run's own changes, the target is DONE: the loop now finds its own bugs, not the repo's. Write a closing report, stop scheduling runs, and say so explicitly. Tuning notes alone never justify a next run.
