# Skill Compatibility

## Core Contract

The shared contract is deliberately small:

```text
skills/packs/<skill-name>/
  SKILL.md
  references/   optional
  scripts/      optional
  assets/       optional
```

`SKILL.md` is Markdown with YAML frontmatter. Consumers should require only:

- `name`
- `description`

Everything else is optional metadata. Unknown keys should be ignored.

## Claude

Claude can use the core skill folders directly:

```bash
cp -R skills/packs/<skill-name> ~/.claude/skills/
```

Claude subagents are not generic skills. They live in `adapters/claude/agents/` and may include Claude-only fields such as `model`, `color`, or `memory`.

## Codex

Codex can also use the core skill folders directly:

```bash
cp -R skills/packs/<skill-name> ~/.codex/skills/
```

Keep descriptions concise. Codex loaders have stricter frontmatter description limits than a human reading Markdown.

## Other Agents

Other runtimes should:

1. Parse or ignore YAML frontmatter.
2. Read the Markdown body.
3. Resolve relative paths from the skill folder.
4. Map tool names to equivalent local tools.
5. Ignore unsupported runtime metadata.

## What Is Not Portable

These are adapters, not core skills:

- model names
- Claude subagents
- Codex plugin manifests
- slash commands
- MCP server configuration
- permission settings
- local machine paths

If one of those is useful, add it under `adapters/<runtime>/` and keep the core `SKILL.md` usable without it.
