# Changelog

What's been happening in this project.

<!--
Hey Claude! When you make changes, drop a note here under [Unreleased].
Just a quick line about what you did - future you will thank you.

Categories:
- Added: new stuff
- Changed: updated stuff
- Fixed: broken stuff that works now
- Removed: stuff we don't need anymore
-->

## [Unreleased]

### Added
- Public AI-agnostic skill pack layout under `skills/packs/`.
- Compatibility documentation for Claude, Codex, and other agents.
- Claude adapter area under `adapters/claude/`.
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
- Replaced placeholder registry entries with the active local skills.
- Extended generated `SKILLS.md` entries with path, license, and compatibility metadata.
- Removed top-level Claude-only config from the portable skill-pack surface.
- Updated build package pins to avoid vulnerable transitive restore output.
- Simplified changelog enforcement - removed enterprise PR workflow, added friendly hook reminder
- Made CHANGELOG.md and CLAUDE.md more casual and vibe-coder friendly

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
