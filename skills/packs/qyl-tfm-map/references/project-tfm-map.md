# qyl-workspace TFM map — authoritative per-project table

Loaded by the `qyl-tfm-map` skill. **Read directly from the `.csproj` files in `~/RiderProjects/qyl-workspace` on 2026-06-13** — 75 project targets on `net10.0`, 7 on `netstandard2.0`. If the repos have changed since, re-derive with the command in `SKILL.md` and update this file; do not trust it past a build that contradicts it.

## The netstandard2.0 island (7 csproj — the only escapes from net10)

### Pure Roslyn components — `netstandard2.0`, `IsRoslynComponent`, never run at runtime
| Project | Repo | Notes |
|---|---|---|
| `qyl.instrumentation.generators` | qyl (`internal/`) | source generator; AOT/trim analyzers force-disabled |
| `qyl.collector.storage.generators` | qyl (`internal/`) | source generator |
| `Qyl.OpenTelemetry.SemanticConventions.SourceGeneration` | Qyl.OpenTelemetry.SemanticConventions (`src/`) | `IncrementalGenerator`; `AssemblyName` is `.Generator`-suffixed, PackageId is not |
| `Qyl.OpenTelemetry.SemanticConventions.Analyzers` | Qyl.OpenTelemetry.SemanticConventions (`src/`) | analyzers + codefixes; `EnforceExtendedAnalyzerRules`; `ImplicitUsings` disabled (explicit `<Using>` items) |
| `Qyl.AutoInstrumentation.SourceGenerators` | qyl-dotnet-autoinstrumentation (`src/`) | "the ONLY project that escapes the net10.0 / AOT baseline" (its own comment); pulls `ANcpLua.Roslyn.Utilities.Sources` |

### Multi-targeted libraries — `net10.0;netstandard2.0` (code must compile on BOTH; obey the netstandard2.0 ceiling)
| Project | Repo | Notes |
|---|---|---|
| `Qyl.OpenTelemetry.SemanticConventions` | Qyl.OpenTelemetry.SemanticConventions (`src/`) | the netstandard2.0 leg is for broad consumer reach; `NU1701` suppressed on that leg |
| `Qyl.OpenTelemetry.SemanticConventions.Incubating` | Qyl.OpenTelemetry.SemanticConventions (`src/`) | same shape as above |

## False friends — look like the island, are actually net10.0

| Project | Why you'd guess wrong | Actual TFM |
|---|---|---|
| `Qyl.OpenTelemetry.SemanticConventions.Analyzers.DocsGenerator` | "Analyzers" + "Generator" in the name | **net10.0** — an Exe build tool that *consumes* the analyzer; it is not loaded into the compiler |
| `Qyl.AutoInstrumentation` (runtime lib) | sits next to `.SourceGenerators`; instrumentation "feels" low-level | **net10.0** — only the `.SourceGenerators` sibling is netstandard2.0 |

## The net10.0 baseline (everything else — ~75 targets)

Not enumerated project-by-project (it is the default and the majority). Anything not listed in the island table above is `net10.0`. Includes: all runtime libraries, all test projects (xUnit v3 on MTP, TUnit), benchmarks, demos, eval/smoke/build tooling. Centralized defaults:

| Repo | Central Pkg Mgmt | Directory.Build.props sets |
|---|---|---|
| qyl | yes | `<TargetFramework>net10.0</TargetFramework>`; `WarningsAsErrors=CA1816;CA2000;CA2012;CA2016`; `EnableNETAnalyzers` |
| Qyl.AutoInstrumentation | yes | `LangVersion=latest; Nullable=enable; ImplicitUsings=enable` |
| Qyl.OpenTelemetry.SemanticConventions | yes | lang defaults + `NU1701` suppressed on the netstandard2.0 leg |
| qyl-dotnet-autoinstrumentation | no | lang defaults + the `MicrosoftCodeAnalysis*Version` / `ANcpLua*` analyzer-version properties |
| qyl-tracker-companion | yes | `<TargetFramework>net10.0</TargetFramework>` |
| qyl-api-schema | no | (per-project) |

> The default is `net10.0`. A project is on the island **only** if its own `.csproj` says `netstandard2.0`. When in doubt, read the csproj — never infer from the folder or assembly name.
