---
description: Build the solution
argument-hint: "[config]"
allowed-tools:
  - Bash(dotnet build:*)
  - Bash(dotnet restore:*)
  - Read
---

# Build Command

Build the ancplua-skills solution.

## Arguments
- `$ARGUMENTS` - Optional: configuration (Debug/Release)

## Actions

1. If no argument provided, use Debug configuration
2. Run `dotnet build ancplua-skills.slnx -c {config}`
3. Report build status and any warnings/errors
