# Baseline gate

On every run after the first over the same target:

- Re-measure and compare against the recorded baseline. **A score below baseline is itself a finding**: name the regressed files/areas (the mutants that survive now but were killed at baseline) and judge them like any other survivor. A maintenance run that lowered the score has weakened the suite even if all its tests pass.
- Survivors in **new code** (added since the baseline) get the same apply-fail-revert-verified killing tests as hunting mode; new code never inherits the old baseline's tolerance.
- When the remaining survivors are only cosmetics and equivalent mutants, **keep the gate running but stop active hunting**. The gate's job from then on is detecting regression, not manufacturing work: chasing equivalents burns runs for zero behavior pinned (a real target went 82.47 -> 92.47 -> 94.12 and then held; further hunting found nothing that mattered).
- Record the new score as the baseline for the next run only when it is >= the old one.
