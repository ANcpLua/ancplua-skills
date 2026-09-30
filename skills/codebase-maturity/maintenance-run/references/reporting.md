# Run report and next run (phases 6-7)

## 6. Run report

Record: findings confirmed and fixed, clusters refuted (with the refutations), baselines before/after, the findings-curve datapoint (total findings, and how many were regressions of the previous run's own changes), and tuning notes for the routine itself.

## 7. Next run opens with /code-review

The next run's first finder is the built-in `/code-review` over THIS run's diff. The previous change-set is the newest code in the repo and the least reviewed; it gets the adversarial pass before anything else does.
