---
description: Format code and YAML files
argument-hint: "[check|fix]"
allowed-tools:
  - Bash(dotnet format:*)
  - Bash(yamllint:*)
  - Read
---

# Format Command

Format C# and YAML files.

## Arguments
- `$ARGUMENTS` - Mode: check (verify only) or fix (apply changes)

## Actions

### check
1. Run `dotnet format ancplua-skills.slnx --verify-no-changes`
2. Run `yamllint skills/*.yaml`
3. Report any formatting issues

### fix
1. Run `dotnet format ancplua-skills.slnx`
2. Report files modified
