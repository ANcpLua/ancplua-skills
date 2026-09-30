# AGENTS.md

Three .NET domains must be flawless: MSTest tests on Microsoft.Testing.Platform, the Fallout build, and Roslyn analyzers and generators. Each has a skill that carries its rules. This file makes loading that skill mandatory, and the project files decide when it applies.

## Routing, before the first edit

1. For every file you will touch, read its owner project: the nearest `*.csproj` plus the `Directory.Build.props`, `Directory.Packages.props` and `global.json` above it. The domain comes from what these files contain, not from file or project names.
2. Match them against the table. On a hit, load every listed skill before you write anything, and open your reply with the route, e.g. `MSTest -> mstest-extensions`. A project can hit several rows; load all of them.
3. On no hit, work without these skills.

| Domain | Hit when the project files contain | Load |
|---|---|---|
| MSTest on MTP | `Sdk="MSTest.Sdk`, an `MSTest.Sdk` entry under `global.json` `msbuild-sdks`, or a `MSTest` / `MSTest.TestFramework` package reference | `mstest-extensions`; add `mstestlean` when `LeanTest.MSTest` is referenced; add `test-audit` when the task deletes, prunes, merges or counts tests |
| Fallout build | a project referencing `Fallout.Common` or `Nuke.Common`; also any edit to `build.sh`, `build.ps1`, `build.cmd`, `.fallout/`, `.nuke/` or a workflow the build generates | `fallout-build` |
| Analyzer purity | `<IsRoslynComponent>true`, `<EnforceExtendedAnalyzerRules>true`, or a `Microsoft.CodeAnalysis.*` package reference in a `netstandard2.0` project | `analyzer-purity`; add `gear-1` in the ANcpLua repos; add `qyl-tfm-map` inside `qyl-workspace` |

To load a skill, invoke it by name (Claude Code: `ancplua-skills:<name>`). Without a skill tool, read `skills/<category>/<name>/SKILL.md` from https://github.com/ANcpLua/ancplua-skills.

## Done

Work is done when the completion criteria of every loaded skill hold.
