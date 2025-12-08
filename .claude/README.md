# Claude Code Configuration

This directory contains Claude Code extensibility configuration for ancplua-skills.

## Structure

```
.claude/
├── settings.json        # Hooks, permissions, environment
├── commands/            # Slash commands
│   ├── build.md         # /build - Build solution
│   ├── skills.md        # /skills - Skills management
│   ├── format.md        # /format - Code formatting
│   └── docker.md        # /docker - Container operations
├── agents/              # Subagents
│   └── skills-validator.md  # Skills registry validator
└── scripts/
    └── statusline.sh    # Custom status display
```

## Hooks

| Event | Action |
|-------|--------|
| PostToolUse (C# files) | Auto-format with `dotnet format` |
| PostToolUse (YAML files) | Validate with `yamllint` |
| PreToolUse | Block writes to .env, .git/, secrets/ |
| SessionStart | Display SDK, branch, skills count |

## Permissions

### Allowed
- `dotnet build/test/format/run`
- `nuke` targets
- `git` operations (non-destructive)
- `docker` and `docker compose`
- `yamllint` validation
- Read/write to `skills/`, `ancplua-skills/`

### Denied
- Read `.env`, `secrets/`
- Edit `.git/`
- Destructive commands (`rm -rf`, `git push --force`)

## Usage

Slash commands are available in Claude Code:
```
/build Release      # Build in Release mode
/skills generate    # Regenerate SKILLS.md
/skills validate    # Validate registry
/format check       # Check formatting
/docker build       # Build container
```
