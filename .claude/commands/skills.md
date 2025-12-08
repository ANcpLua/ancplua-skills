---
description: Generate or validate skills
argument-hint: "[generate|validate|list]"
allowed-tools:
  - Bash(nuke:*)
  - Bash(yamllint:*)
  - Read
  - Grep
---

# Skills Command

Manage skills registry and generation.

## Arguments
- `$ARGUMENTS` - Action: generate, validate, or list

## Actions

### generate
Run `nuke GenerateSkills` to regenerate SKILLS.md from registry.

### validate
Run `nuke ValidateSkills` to check YAML schema and references.

### list
Display all active skills from skills-registry.yaml with their categories.

## Files
- `skills/skills-registry.yaml` - Skill definitions
- `skills/skills-categories.yaml` - Category definitions
- `skills/templates/SKILLS.template.md` - Generation template
- `SKILLS.md` - Generated output
