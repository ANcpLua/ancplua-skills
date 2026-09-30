# Fault classes

Drill into each finding with `slice` until you can put it in exactly one class:

1. **Infrastructure fault**: API errors and overload dead-ends, limit-interrupts with no continuation after. The provider or harness stopped the run, not the agent. The fix is checkpoint/resume habits and retry cadence, never prompt blame.
2. **Agent-native fault**: retry-loops (same tool, same error signature, 3+ consecutive), hot tools with outlier error rates, sessions ending on an unhandled tool error. The agent's routine failed. The fix is routine tuning: a fallback after the second identical failure, a different tool choice, reading the error signature instead of re-running.
3. **User-flow fault**: permission-thrash (repeated denial results, plus relayed denial reports — the finding says how many of each), silence-gaps clustered around approval points. The human-in-the-loop is the bottleneck; each denial *result* names the exact tool call behind it, and only those feed allowlist proposals.
