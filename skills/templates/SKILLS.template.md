# Skills Registry

> Auto-generated from `skills-registry.yaml` - Do not edit directly

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      AI-AGNOSTIC SKILL PACK INDEX                           │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────┐   ┌─────────────┐   ┌─────────────┐                       │
│  │   Global    │ → │   Domain    │ → │   Session   │                       │
│  │   Skills    │   │   Skills    │   │   Skills    │                       │
│  └─────────────┘   └─────────────┘   └─────────────┘                       │
│        ↓                 ↓                 ↓                                │
│   [BASELINE]        [PROJECT-SCOPED]   [RUNTIME-LOADED]                    │
│   Doc routing       MCP/Web/etc.       Task-specific                       │
│   Always available  Per-domain         On-demand activation                │
│                                                                             │
│  LOADING: Stateless. Each session = fresh parse + merge by priority.       │
│  WEIGHT: Session > Domain > Global (later overrides earlier)               │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Quick Stats

| Scope | Active | Total |
|-------|--------|-------|
{{STATS_TABLE}}

---

## Contents

{{TABLE_OF_CONTENTS}}

---

{{BODY_SECTIONS}}

---

## Skill Loading Order

Skills are merged in priority order within each scope:

1. **Global Skills** (always loaded first)
2. **Domain Skills** (loaded based on project detection)
3. **Session Skills** (loaded on-demand or by trigger)

Within each scope, lower `priority` numbers load first.

---

## Skill Folder Contract

Each entry points to a folder with a `SKILL.md` file. The portable contract is intentionally small:

- YAML frontmatter with at least `name` and `description`.
- Markdown instructions in the body.
- Optional `references/`, `scripts/`, `assets/`, or runtime adapter files.
- Relative paths in `SKILL.md` are resolved from that skill folder.

Unsupported frontmatter keys should be ignored by runtimes that do not know them.

## Activation Triggers

| Trigger Type | Description |
|--------------|-------------|
| `project_type:*` | Activates for specific project types |
| `file_type:*` | Activates for specific file extensions |
| `error_detected` | Activates when an error/exception occurs |
| `test_run_complete` | Activates after test execution |
| `user_request` | Manual activation only |
| free-form keywords | Runtimes may map natural-language trigger strings to their own routing model |

---

<sub>Generated: {{GENERATION_TIMESTAMP}} | Skills: {{TOTAL_SKILLS}} | Categories: {{TOTAL_CATEGORIES}}</sub>
