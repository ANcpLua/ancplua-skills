---
name: agent-log-scan
description: Scan agent transcripts and turn antipatterns into config and routine changes, not just an allowlist like fewer-permission-prompts. Use when asked to scan agent logs or session history, "why do my agents keep failing", "what happened across my sessions", to find retry loops, permission thrash, API dead-ends or limit interrupts, or raise autonomy.
---

# Agent log scan

Mine a transcript corpus with the bundled scanner and read only its aggregate. The agent never reads raw logs. Read a reference only when its step needs it:

- [references/scanner.md](references/scanner.md): privacy flag, `slice`/`bisect` drill-down, exit codes.
- [references/fault-classes.md](references/fault-classes.md): class definitions and fixes, when judging.
- [references/detector-anchoring.md](references/detector-anchoring.md): before extending or doubting a detector.
- [references/allowlist-rules.md](references/allowlist-rules.md): before proposing any permission rule.
- [references/ledger.md](references/ledger.md): pricing subagent workflow runs before a new maintenance target.

## Steps

1. **Scan**: `scripts/agentlog.py scan <corpus>` on `~/.claude/projects` or one project folder. Read ONLY the aggregate it prints. Never open or `cat` a `.jsonl`.
2. **Judge**: `slice` into each finding until it fits exactly one class: infrastructure, agent-native, or user-flow fault.
3. **Ship** a change list that raises the approval/autonomy range from mass data: allowlist additions for the exact calls behind permission-thrash (proposed, never applied); routine tuning from each retry-loop's error signature; harness config for infrastructure faults (checkpoint cadence, session-resume habits, scheduling around usage-limit windows).
4. **Summarize**: sessions scanned, antipatterns by class, top error clusters, the change list, with zero raw log lines having entered context.
