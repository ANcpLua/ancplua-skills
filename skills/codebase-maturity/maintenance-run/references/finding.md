# Finders and root-cause dedupe (phases 1-2)

## 1. Scope and finders

Fix the target scope, then launch read-only finders in parallel, one per dimension. Reuse the sibling maturity routines as finder dimensions where they fit: mutation-tester (test-gap hunting, mutation-score baseline), emitter-corpus (interop/parser truth), perf-gate (performance claims), agent-log-scan (harness/autonomy health), plus code-reading finders for logic, merge, and boundary bugs. Every raw finding needs evidence: a repro command, a failing input, a measurement — not a vibe.

## 2. Dedupe by root cause BEFORE verification

Mechanical first: collect the raw findings as JSON (`title`/`file`/`category` required; `line`, `severity`, `evidence`, `dimension` strongly encouraged; per-finding `root_cause` is REQUIRED in the finder handoff — the signature rule bites on it, and title-only output demonstrably under-merges: on run-002's replay it reached none of the cross-file merges) and run `scripts/findings.py dedupe <findings.json>` (Python 3 stdlib, deterministic: same input, byte-identical output; `validate` gates the finder handoff).

It merges only what is provably mechanical — root-cause signatures with ≥ 1/2 token-set overlap after agentlog-style normalization (paths/ids/hex/numbers stripped), or identical normalized titles — takes the transitive closure, picks each cluster's primary by severity then evidence, and reports every merge edge with its reason.

Line proximity never merges: on run-002's ground truth, 4 of 7 same-file near-line pairs were distinct claims and no window setting separates them (the closest false pair sat 1 line apart, a true pair 14 apart), so same-file pairs within ±15 lines are flagged on the `ambiguous` list with their distance instead of being fused.

Exit 2 means merges happened, 0 means nothing merged, 1 means the findings file is malformed (fix the finder output, don't hand-edit).

The dedupe arbiter then works the tool's `ambiguous` list — file-window pairs and near-threshold signature pairs — reading the code where the pair text is not enough. Tool merges are a floor, not a ceiling: the arbiter may SPLIT a tool cluster with a stated reason, and may MERGE pairs the tool did not flag when it states the shared root cause with evidence from the code — run-002's cross-file duplicate-policy cluster is reachable only this way when finders skimp on `root_cause`. What the arbiter never does is re-cluster from scratch or depart from tool output without stated evidence.

Two findings whose fixes land on the same code for the same reason are one cluster. Verifying raw findings wastes verifier passes refuting duplicates after the fact; verifying clusters spends every pass on a distinct claim.
