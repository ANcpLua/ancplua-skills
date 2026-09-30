# Interpreting findings

Use `RuleCatalog` for the exact SR1-SR6 contracts. Persistence recognition uses type-name conventions, and publication depends on explicit configuration; framework identity and publication intent must be checked against source. `ARCH*` configuration diagnostics remain in raw logs and are absent from the aggregated SR counts. `ACFACT` carries shared-store usage evidence, not a separate violation: the reporter aggregates it across the solution into SR4 and deduplicates identical findings across target frameworks. Evaluate that aggregated output instead of adding raw log counts.

## Precision and recall

For requested precision or recall, define the review unit and labeling rubric before sampling. Record the rule, source location or trace, expected ownership and allowance, observed behavior, TP/FP/FN or unresolved label, and supporting evidence. Review undetected cases independently to estimate false negatives. Compute precision as `TP / (TP + FP)` and recall as `TP / (TP + FN)` only for supported denominators; use unavailable for zero denominators or missing ground truth. Report sample sizes, unresolved cases, and exclusions per rule and group. Diagnostic totals alone establish neither precision nor architectural quality.
