# CLAUDE.md

Project instructions for Claude Code when working with ancplua-skills.

## Overview

**ancplua-skills** is a Claude Code skills registry and generator. It provides:
- YAML-based skill definitions with schema validation
- Template-driven SKILLS.md generation via NUKE
- Docker containerization for deployment
- GitHub Actions CI with Anthropic best practices validation

## Build Commands

```bash
# Build solution
dotnet build ancplua-skills.slnx

# Build with NUKE
./build.sh Compile          # or: nuke Compile

# Generate SKILLS.md from registry
./build.sh GenerateSkills   # or: nuke GenerateSkills

# Validate skills schema
./build.sh ValidateSkills   # or: nuke ValidateSkills

# Full pipeline (validate + generate)
./build.sh Skills           # or: nuke Skills

# Format code
dotnet format ancplua-skills.slnx

# Validate YAML
yamllint skills/*.yaml
```

## Project Structure

```
ancplua-skills/
├── skills/                          # Skills registry
│   ├── skills-registry.yaml         # Skill definitions
│   ├── skills-categories.yaml       # Category definitions
│   └── templates/
│       └── SKILLS.template.md       # Generation template
├── ancplua-skills/                  # Main .NET project
│   └── Program.cs
├── build/                           # NUKE build system
│   ├── Build.cs                     # Build targets
│   └── SkillsFramework/             # Generation library
├── .claude/                         # Claude Code configuration
│   ├── settings.json                # Hooks, permissions
│   ├── commands/                    # Slash commands
│   └── agents/                      # Subagents
├── .github/workflows/               # CI pipelines
│   ├── validate-skills-bestpractises.yml
│   └── docker-publish.yml
├── SKILLS.md                        # Generated output
└── Directory.Build.props            # .NET build settings
```

## Skills Registry Schema

### Required Skill Fields
```yaml
skills:
  - id: prefix-hash           # Unique ID (prefix-hash pattern)
    name: "Skill Name"        # Display name
    category: category-id     # Reference to skills-categories.yaml
    scope: global|domain|session
    trigger: "activation keywords"
    activation: automatic|manual
    active: true|false
```

### Category Schema
```yaml
categories:
  - id: category-id
    name: "Category Name"
    prefix: CAT              # Short prefix for skill IDs
    scope: global|domain|session
    order: 1                 # Display order
    subcategories:           # Optional
      - id: subcat-id
        name: "Subcategory"
```

## Code Style (Enforced)

- .NET 10.0 LTS, C# 14
- File-scoped namespaces
- Nullable reference types enabled
- Warnings treated as errors
- EditorConfig enforced

## Docker

```bash
# Build image
docker build -t ancplua/ancplua-skills .

# Run with compose
docker compose up

# Push to Docker Hub (requires DOCKERHUB_TOKEN)
docker push ancplua/ancplua-skills:latest
```

## CI/CD

GitHub Actions validates on every push/PR:
- Directory structure
- Naming conventions (kebab-case)
- YAML syntax (yamllint)
- Skills registry schema
- Categories schema
- Skill-category cross-references
- Template placeholders

## Contributing

1. Fork the repository
2. Run `./build.sh ValidateSkills` before committing
3. Ensure CI passes
4. Submit PR

## Slash Commands

- `/build [config]` - Build solution
- `/skills [generate|validate|list]` - Manage skills
- `/format [check|fix]` - Format code
- `/docker [build|run|push]` - Docker operations
