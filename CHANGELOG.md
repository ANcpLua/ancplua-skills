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
- The repository is an installable Claude Code plugin: `.claude-plugin/plugin.json` lists every skill, `.claude-plugin/marketplace.json` serves it as `ancplua-skills`.
- Skills `test-audit`, `mstestlean`, `gear-1`, `paper-reader` and `plugin-creator`, and the category `productivity`.

### Changed
- Skills live under `skills/<category>/<skill>/` (the registry category), each category with a README; `skills/packs/` is gone and every path in the registry, README, docs, renovate and adapters follows.
- The five `codebase-maturity` imports record their upstream revision (`ANcpLua/maturity-skills` main @ 2ab662b).
- CI parses every `SKILL.md` frontmatter, runs the bundled helper tests (`skills/**/scripts/test_*.py`) and checks the eval scaffold's HOME guard; `ValidateSkills` also scans `.py`, `.csproj`, `.props`, `.targets`, `.xml` and `.claude-plugin/` for machine-local paths.

### Fixed
- `agent-log-scan`: error signatures, printed without `--show-text`, no longer carry e-mail addresses or token-like secrets from the error text.
- `paper-reader`: arXiv e-print extraction skips links and members that resolve outside `source/`; commands reference `scripts/` in the skill folder instead of `~/.claude/skills/paper-reader/`, which a plugin install never creates.
- `mutation-tester`: the frontmatter description is quoted, so strict YAML parsers load it.
- `prove-fix-across-versions` eval scaffold `_smoke/scaffold.sh` refuses to run when HOME is not remapped, instead of rewriting the real user's NuGet config, and pins OLD with a `sed -i` form that works on BSD and GNU sed.
- `mcp-csharp-sdk-1.4.1` is renamed `mcp-csharp-sdk-1-4-1`: skill names allow only lowercase letters, digits and hyphens, and CI now enforces that.
- `forgejo-direct-api`: `verify-forgejo-skill.sh` sends `FORGEJO_TOKEN` only to an instance given as its first argument, never to the public default.


### Added
- `mstest-extensions` skill (`testing` category): the MSTest counterpart of `tunit-extensions` for MSTest 4 on Microsoft.Testing.Platform, with references for data-driven cases, lifecycle and TestContext, assertions and execution control, and MTP runner verification.
- Imported 11 skills into `skills/packs/`, each rewritten against plugin-eval findings (compact `SKILL.md`, "Use when" triggers, detail moved into `references/`): `prove-fix-across-versions` and `tunit-extensions` (new `testing` category), `slnx-rider` and `fallout-build` (`dotnet-platform`; `fallout-build` merges the general Fallout build skill with ArchCheck's build runbook), the `maturity-skills` routines `agent-log-scan`, `emitter-corpus`, `maintenance-run`, `mutation-tester`, `perf-gate` (new `codebase-maturity` category), and the ArchCheck thesis skills `twbook` and `archcheck-evaluation` (new `archcheck-thesis` category). `regression-review` was left out: the built-in `/code-review` covers it.
- `prompt-engineering-expert` skill + new `prompt-engineering` category: diagnose-first help for writing, refining, and debugging prompts, system prompts, agent instructions, CLAUDE.md/AGENTS.md files, and skill trigger descriptions. Ships five references (principles, techniques, failure-modes, examples) plus a Claude Fable 5 / Mythos 5 section: prune-before-you-add migration, symptom→fix snippets, long-run scaffolding, effort selection, and the reasoning-extraction refusal trap.
- `maf-dotnet-source-of-truth` skill + new `dotnet-ai` category: Microsoft Agent Framework (.NET) API guardrails, every rename trap grep-verified against a pinned `microsoft/agent-framework` checkout (AgentThread→AgentSession, AgentRunResponse→AgentResponse, IChatClient.CompleteAsync→GetResponseAsync, …).
- `qyl-tfm-map` skill + new `dotnet-platform` category: maps qyl-workspace projects to their target frameworks (net10.0 baseline vs the netstandard2.0 Roslyn island) and the API/feature constraints each imposes.

### Changed
- Raised `microsoft-first-research` to Gold on the TomeVault quality rubric: added activation triggers, runnable code blocks, named tools, and imperative guidance.
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
- `supercritical-code-quality-review` skill: original strict structural review with adversarial refutation, plus a Claude nested-agent cascade adapter (`supercritical-review-orchestrator`). Carries forward the original diff-scoping workflow (1000-line and conditional-creep smell scans) so no Gold scoping content is lost in the rename.
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
