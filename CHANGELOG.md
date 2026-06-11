# Changelog

What's been happening in this project.

<!--
Agent maintenance note: when you make changes, drop a short line here under
[Unreleased].

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
- `supercritical-code-quality-review` skill: original strict structural review with adversarial refutation, plus a Claude nested-agent cascade adapter (`supercritical-review-orchestrator`).
- Nested sub-agent delegation guidance in the Claude expert agents (Claude Code 2.1.172+ allows sub-agents to spawn sub-agents, 5 levels deep).

### Removed
- `thermo-nuclear-code-quality-review` pack — it was a verbatim copy of Cursor team-kit's unlicensed skill; replaced by the original `supercritical-code-quality-review`.

### Changed
- Replaced placeholder registry entries with the active local skills.
- Extended generated `SKILLS.md` entries with path, license, and compatibility metadata.
- Removed top-level Claude-only config from the portable skill-pack surface.
- Updated build package pins to avoid vulnerable transitive restore output.
- Updated GitHub and Docker Actions from Node 20-backed releases to current Node 24-ready releases.
- Simplified changelog enforcement - removed enterprise PR workflow, added friendly hook reminder
- Clarified CHANGELOG.md and CLAUDE.md maintenance notes.

### Fixed
- Build workflow now properly ignores timestamp when comparing SKILLS.md versions
- Forgejo skill refresh examples now use skill-relative script paths instead of a Claude-specific absolute path.

---

## [0.1.0] - 2025-12-08

### Added
- Initial project setup
- Basic Nuke build scaffolding
- Solution structure with ancplua-skills.slnx

---

[Unreleased]: https://github.com/ANcpLua/ancplua-skills/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/ANcpLua/ancplua-skills/releases/tag/v0.1.0
