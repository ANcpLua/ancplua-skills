---
name: analyzer-purity
description: Keep Roslyn analyzers, source generators and code fixes pure, loadable and cache-friendly inside every compiler host. Use when creating, changing, reviewing or packaging a netstandard2.0 project with IsRoslynComponent, EnforceExtendedAnalyzerRules or Microsoft.CodeAnalysis references, or when an RS1xxx/RS2xxx diagnostic, a sluggish IDE or a generator that reruns on every keystroke points at one.
---

# Analyzer purity

A Roslyn component runs inside every consumer's compiler: Visual Studio on .NET Framework, `dotnet build` and Rider on .NET, and the IDE on nearly every keystroke. It is **pure** when its output depends only on what the compiler hands it (syntax, semantic model, `AdditionalFiles`, analyzer config options) and it loads in every host. The `Microsoft.CodeAnalysis.Analyzers` package checks most of this as RS diagnostics; its `documentation/Microsoft.CodeAnalysis.Analyzers.md` holds the rule text for the installed version.

## Steps

1. **Inventory** every component project and the project that packs it: its csproj, `Directory.Build.props` and `Directory.Packages.props`. The rules hold per project.
2. **Gate** each project on every rule below; a rule that does not hold is the change to make.
3. **Reuse** instead of hand-rolling: in the ANcpLua repos, polyfills, `EquatableArray<T>`, pipeline helpers and analyzer test harnesses come from `gear-1`. Inside qyl-workspace, `qyl-tfm-map` names the netstandard2.0 projects.
4. **Prove**, when asked to build: each component project builds with zero RS1xxx/RS2xxx diagnostics, and the packed `.nupkg` holds the assembly only under `analyzers/dotnet/cs/`.

## Rules

| Rule | Why | Diagnostic |
|---|---|---|
| `TargetFramework` is exactly `netstandard2.0`. | The only target both compiler hosts load. | RS1041 |
| `EnforceExtendedAnalyzerRules` is `true`; no file IO, `Console`, `Process`, `Environment` or `Random`. | Inputs come only from the compilation, `AdditionalFiles` and options; output is deterministic. | RS1035, RS1036 |
| References `Microsoft.CodeAnalysis.CSharp` with `PrivateAssets="all"`, pinned to the oldest compiler it supports; `Workspaces` only in a separate code-fix assembly. | The component loads only on compilers at or above that version; `Workspaces` exists only in the IDE. | RS1038 |
| Generators implement `IIncrementalGenerator`; pipeline models are equatable values and never hold `ISymbol`, `SyntaxNode`, `SemanticModel` or `Compilation`. | Equal models are cache hits; a held compilation is a leak and a rerun on every edit. | — |
| Analyzers call `EnableConcurrentExecution` and `ConfigureGeneratedCodeAnalysis` and keep no static mutable state. | The host runs them in parallel and repeatedly. | RS1026, RS1025 |
| Every diagnostic ID has a row in `AnalyzerReleases.Unshipped.md` or `AnalyzerReleases.Shipped.md`. | A changed or removed ID shows up as a breaking change. | RS2008 |
| The package puts the assembly under `analyzers/dotnet/cs/`, sets `IncludeBuildOutput` to `false` and bundles runtime dependencies beside it. | Only that folder is loaded as an analyzer; anywhere else it becomes a library reference. | — |

Done when every rule holds for every component project in scope.
