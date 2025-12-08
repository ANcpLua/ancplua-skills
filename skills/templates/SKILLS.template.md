# Skills Registry

> Auto-generated from `skills-registry.yaml` - Do not edit directly

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         SKILLS.md CONTEXT LOADING                           │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────┐   ┌─────────────┐   ┌─────────────┐                       │
│  │   Global    │ → │   Domain    │ → │   Session   │                       │
│  │   Skills    │   │   Skills    │   │   Skills    │                       │
│  └─────────────┘   └─────────────┘   └─────────────┘                       │
│        ↓                 ↓                 ↓                                │
│   [IMMUTABLE]       [PROJECT-SCOPED]   [RUNTIME-LOADED]                    │
│   Core agents       .NET/Web/etc.      Task-specific                       │
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

## Activation Triggers

| Trigger Type | Description |
|--------------|-------------|
| `on_file_open` | Activates when a file is opened |
| `on_save` | Activates when a file is saved |
| `project_type:*` | Activates for specific project types |
| `file_type:*` | Activates for specific file extensions |
| `error_detected` | Activates when an error/exception occurs |
| `test_run_complete` | Activates after test execution |
| `user_request` | Manual activation only |

---

<sub>Generated: {{GENERATION_TIMESTAMP}} | Skills: {{TOTAL_SKILLS}} | Categories: {{TOTAL_CATEGORIES}}</sub>
