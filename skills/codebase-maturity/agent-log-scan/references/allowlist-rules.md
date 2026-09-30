# Allowlist conduct rules

Denial evidence authorizes narrow proposals, never self-service:

- Propose only operations that are **read-only, high-frequency, and unambiguous**, and only when each proposed rule is backed by an observed denial in the scan (the finding's `file:line` is the citation).
- Never propose allowlisting writes, deletes, installs, network sends, or anything whose safety depends on its arguments. If an operation is ambiguous, it stays behind the prompt.
- Settings and permission-config changes are always **proposed to the human, never applied by the agent**. Present the exact `permissions.allow` rules (or hand off to the fewer-permission-prompts routine) and stop; observed sessions show agents retrying config self-edits through different write mechanisms after a denial — up to four attempts — and every such attempt is itself permission-thrash.
