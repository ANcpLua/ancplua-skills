# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

<!--
═══════════════════════════════════════════════════════════════════════════════
CHANGELOG MAINTENANCE RULES (Enforced by CI)
═══════════════════════════════════════════════════════════════════════════════

1. EVERY pull request MUST update this file
2. Add entries under [Unreleased] section
3. Use these categories:
   - Added: New features
   - Changed: Changes in existing functionality
   - Deprecated: Soon-to-be removed features
   - Removed: Removed features
   - Fixed: Bug fixes
   - Security: Vulnerability fixes

4. Format: `- Description of change (#PR_NUMBER)`
5. Keep entries concise but descriptive
6. Link to relevant issues/PRs when applicable

═══════════════════════════════════════════════════════════════════════════════
-->

## [Unreleased]

### Added
- Initial Skills Framework with YAML-driven skill registry
- Nuke build system with GenerateSkills and ValidateSkills targets
- SkillsGenerator for YAML → Markdown template generation
- GitHub Actions workflows:
  - `build.yml` - .NET build and Docker test
  - `validate-skills-bestpractises.yml` - Skills structure validation
  - `docker-publish.yml` - Docker Hub publishing (disabled)
- Dependabot configuration for NuGet and GitHub Actions
- Comprehensive .gitignore for Rider, C#, Node.js, Python
- Root .editorconfig with C#, YAML, shell settings
- Root Directory.Build.props for solution-wide configuration
- Dockerfile for .NET 10 multi-stage build
- MIT License

### Changed
- N/A

### Fixed
- Build workflow now properly ignores timestamp when comparing SKILLS.md versions

---

## [0.1.0] - 2025-12-08

### Added
- Initial project setup
- Basic Nuke build scaffolding
- Solution structure with ancplua-skills.slnx

---

[Unreleased]: https://github.com/ANcpLua/ancplua-skills/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/ANcpLua/ancplua-skills/releases/tag/v0.1.0
