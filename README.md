# ancplua-skills

Public, AI-agnostic skill pack.

The portable unit is a directory containing `SKILL.md`. Claude, Codex, and other agents can all consume that shape because it is plain Markdown with small YAML frontmatter. Runtime-specific files, such as Claude subagents or local permission config, belong under `adapters/` and are not part of the core contract.

## What Is Portable

Portable:

- `skills/packs/<skill>/SKILL.md`
- optional `references/`, `scripts/`, and `assets/` under the skill folder
- frontmatter keys such as `name`, `description`, `license`, `metadata`
- Markdown routing tables and relative links

Runtime-specific:

- Claude subagents
- slash commands
- permission settings
- MCP connector configuration
- model names such as `opus`, `sonnet`, or OpenAI model slugs

Those runtime-specific pieces live in `adapters/`.

## Skills

The generated index is [SKILLS.md](SKILLS.md).

Current core skills:

- `c4-diagram`
- `forgejo-direct-api`
- `maf-dotnet-source-of-truth`
- `mcp-csharp-sdk-1.4.0`
- `microsoft-first-research`
- `microsoft-learn-grounding`
- `qyl-tfm-map`
- `react-bits-pro`
- `supercritical-code-quality-review`

## Install

Claude:

```bash
mkdir -p ~/.claude/skills
cp -R skills/packs/<skill-name> ~/.claude/skills/
```

Codex:

```bash
mkdir -p ~/.codex/skills
cp -R skills/packs/<skill-name> ~/.codex/skills/
```

Any other model/runtime:

1. Read `SKILL.md`.
2. Resolve relative paths from that skill directory.
3. Ignore unsupported frontmatter keys.
4. Map tool names and connector names to equivalent local capabilities.

## Credentials

No real secrets are stored in this repo. Some skills mention environment variables such as `FORGEJO_TOKEN` or `REACTBITS_LICENSE_KEY`; those are placeholders and must be supplied by the user in their own environment.

`react-bits-pro` is instructions-only and requires the user's own React Bits Pro access.

## Generate The Index

```bash
./build.sh GenerateSkills
```

Validation:

```bash
./build.sh ValidateSkills
dotnet build ancplua-skills.slnx --nologo
```

## License

Repository wrapper content is MIT unless a skill declares a narrower upstream license or access requirement in its own `SKILL.md` or registry entry.
