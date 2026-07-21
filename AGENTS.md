# Agent Instructions

This repo is an AI-agnostic skill pack. Keep the core contract portable:

- Put reusable skills in `skills/packs/<name>/SKILL.md`.
- Keep runtime-specific adapters in `adapters/<runtime>/` (e.g. Claude-specific
  reusable files live under `adapters/claude/`); the core skills under
  `skills/packs/` stay model-agnostic.
- Do not put real credentials, tokens, license keys, private repository URLs, or local-only secrets in committed files.
- If a skill needs a credential, document the environment variable name only.
- Regenerate `SKILLS.md` after editing `skills/skills-registry.yaml`, `skills/skills-categories.yaml`, or `skills/templates/SKILLS.template.md`.

Useful commands:

```bash
./build.sh GenerateSkills
./build.sh ValidateSkills
dotnet build ancplua-skills.slnx --nologo
```
