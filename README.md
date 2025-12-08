# ancplua-skills

A YAML-driven skills registry framework for Claude Code agents with hierarchical scope management.

## Overview

This framework provides a structured way to define, organize, and generate skill documentation for AI coding assistants. Skills are organized into three scope levels:

- **Global Skills** - Always loaded, core capabilities
- **Domain Skills** - Project-type specific (e.g., .NET, React, TypeScript)
- **Session Skills** - On-demand activation for specific tasks

## Quick Start

### Prerequisites

- .NET 10.0 SDK
- Nuke build system

### Generate SKILLS.md

```bash
./build.sh GenerateSkills
```

### Validate Skills Structure

```bash
./build.sh ValidateSkills
```

## Project Structure

```
ancplua-skills/
├── skills/
│   ├── skills-registry.yaml      # All skill definitions
│   ├── skills-categories.yaml    # Category hierarchy
│   ├── skill-overrides.yaml      # Optional overrides
│   └── templates/
│       └── SKILLS.template.md    # Output template
├── build/
│   ├── Build.cs                  # Nuke build targets
│   └── SkillsGenerator.cs        # Template engine
├── SKILLS.md                     # Generated output
└── Dockerfile                    # Container support
```

## Skills Registry Schema

Each skill in `skills-registry.yaml` has:

| Field | Required | Description |
|-------|----------|-------------|
| `id` | Yes | Unique identifier (format: `prefix-hash`) |
| `name` | Yes | Display name |
| `category` | Yes | Parent category ID |
| `scope` | Yes | `global`, `domain`, or `session` |
| `trigger` | Yes | Activation trigger |
| `activation` | Yes | `automatic` or `manual` |
| `active` | Yes | Enable/disable flag |
| `priority` | No | Load order (lower = first) |
| `capabilities` | No | List of capability tags |

## CI/CD

### Validation Workflow

The `validate-skills-bestpractises.yml` workflow runs on every push to `skills/**` and validates:

- Directory structure
- Naming conventions (kebab-case for YAML files)
- YAML syntax
- Schema compliance
- Cross-references between skills and categories
- Template placeholders

### Docker Publishing

The `docker-publish.yml` workflow is disabled by default. Enable it by removing `if: false` from the job.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

Alexander Nachtmann
