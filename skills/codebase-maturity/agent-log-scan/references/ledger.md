# Workflow efficiency ledger

`scripts/agentlog.py ledger <workflows-root-or-project-dir>...` aggregates subagent workflow runs (`wf_*/` dirs holding `journal.jsonl` + `agent-<id>.jsonl`) into a per-run/per-agent table: agents started/completed, tool calls, output tokens, input+cache tokens, context tokens (each agent's final context footprint — the same figure the workflow runner reports as per-agent tokens), wall and per-agent durations, and agent labels. Deterministic, streaming, and privacy-default like the rest of the tool: labels and numbers only, never prompt or message text. `--outcomes <json>` joins a run-id -> `{confirmed, fixed, tests_added, mutants_killed, note}` map and adds a tokens-per-finding column; `--json` is the machine form.

The routine:

- Run the ledger **before starting a new maintenance target** so the scale decision is priced, not guessed: what did the last comparable run cost in agents, tokens, and wall time?
- Keep the outcomes file current (one entry per finished run) and **compare tokens-per-finding across runs**: a 14-agent sweep that lands 49 confirmed findings at ~22k context tokens each beats a 6-agent run landing 2 findings at ~240k each; the delta is the argument for changing fleet size, wave structure, or target choice.
- Feed the numbers into scale decisions explicitly — pick agent counts and phase splits from the cheapest tokens-per-finding shapes in the ledger, and say so in the plan. Fleet size is a cost knob with measured settings, not a vibe.
