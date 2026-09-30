---
name: perf-gate
description: Measure a project's own performance claims (README, docs) against reality and attribute regressions to code. Use when the user asks to verify a performance claim, benchmark a tool, check "does it really handle X MB / X requests", validate streaming or O(n) claims, or establish a perf baseline.
---

Find the project's own performance claims (README, docs, package descriptions: "streaming", "handles X MB", "zero-allocation", "O(n)") and measure each against the real built artifact. An unmeasured claim is a bug report waiting in a user's terminal.

## Ground rules

- Measure the real artifact (installed binary / release build), not a debug harness.
- Commit generator and harness files (e.g. `gen.py`, `bench.sh`) to a scratch area so the next run reproduces the exact workload.
- 3+ runs per cell, report medians; measure wall time AND peak memory (`/usr/bin/time -l` on macOS, `-v` on Linux).
- Scale inputs across 3+ sizes (e.g. 1x, 10x, 50x) so growth curves show; include the many-small-inputs merge path, not just one big input.

## Judge: attribute before accusing

1. Read the code behind each number first: separate legitimate retained-model growth from streaming failure, and startup from per-item cost.
2. Findings: contradicted claims (including hard limits capping the claimed size); superlinear growth where linear is claimed or expected (quadratic merge folds, per-item rescans); memory scaling with input where streaming is claimed; hangs/crashes within the claimed envelope; user-reachable limits with no override or actionable error.
3. Evidence per finding: measurement table, responsible code location, contradicted claim text.
4. Always report the full measurement table; a green one is the next run's perf regression baseline.

End with a summary: claims validated, claims contradicted (with numbers), limits documented vs undocumented, baseline table.
