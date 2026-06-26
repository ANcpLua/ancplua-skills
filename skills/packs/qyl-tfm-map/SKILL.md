---
name: qyl-tfm-map
description: >-
  Know, without being told, which target framework every project in ~/RiderProjects/qyl-workspace
  compiles for and what that allows or forbids — the net10.0 baseline (full modern BCL, AOT/trim-aware)
  versus the small netstandard2.0 Roslyn island (source generators + analyzers + the multi-targeted OTel
  libs). USE FOR: editing or reviewing any C# in qyl, Qyl.AutoInstrumentation, qyl-dotnet-autoinstrumentation,
  Qyl.OpenTelemetry.SemanticConventions; choosing whether an API/language feature is legal in the file you are
  touching; a build error like CS0103/CS1061/CS8370/"is not available in netstandard2.0" inside a
  *.SourceGenerators / *.Analyzers / *.generators project; "can I use HashCode / System.Text.Json /
  ArgumentNullException.ThrowIfNull / Span here"; reviewing a PR that spans both a generator and its runtime
  consumer. ESPECIALLY use it before you assume a *.SourceGenerators project can call net10 BCL (it cannot —
  it is netstandard2.0), or that netstandard2.0 forbids records / init / required (it does NOT — those are
  polyfilled). Both of those instincts are wrong here and this skill exists to override them.
  DO NOT USE FOR: the agent-framework-dotnet-rootsource checkout (that is upstream Microsoft source, not a qyl
  project); picking a test framework or test platform; NuGet publishing mechanics (use nuget-trusted-publishing).
license: Apache-2.0
---

# qyl TFM Map — net10.0 everywhere, except the netstandard2.0 Roslyn island

**Provenance: every TFM in this skill was read directly from the `.csproj` files in `~/RiderProjects/qyl-workspace` on 2026-06-13** — not remembered, not assumed. Counts at that time: **75 project targets on `net10.0`, 7 on `netstandard2.0`.** The exact per-project list lives in [references/project-tfm-map.md](references/project-tfm-map.md); re-derive it any time with the command at the bottom of this file. Treat anything you remember about "generators can use modern .NET" as wrong here.

> 🚨 **The compiler hosts source generators and analyzers in a `netstandard2.0` process. Any project that ships INTO the Roslyn compiler must be `netstandard2.0` — it cannot see the net10 BCL.** This is the one fact that, missed, produces a green-on-your-machine edit that breaks the build for everyone.

## The rule that overrides your instinct

Two opposite mistakes, both common, both wrong in this workspace:

1. **"It's a generator, but I'll just use `System.Text.Json` / `HashCode` / `ArgumentNullException.ThrowIfNull` / a `Span` BCL overload."** — ❌ No. Those are net10 *runtime* APIs and the project is `netstandard2.0`. Use the polyfilled equivalent (see the cookbook).
2. **"It's `netstandard2.0`, so no records, no `init`, no `required`, no collection expressions."** — ❌ Also no. `LangVersion=latest` applies even on the island, and `ANcpLua.Roslyn.Utilities.Sources` (source-only, `PrivateAssets=all`) ships the compiler-required attributes. **Modern C# *syntax* is fully legal; only the net10 *runtime API surface* is not.**

**The dividing line is syntax (allowed) vs runtime BCL (not), not "old framework = old language."** Get that one distinction right and almost every island question answers itself. Details and the substitution table: [references/netstandard20-cookbook.md](references/netstandard20-cookbook.md).

## When to Use

Use this skill whenever you are working anywhere under `~/RiderProjects/qyl-workspace` and one of these is true:

- You are about to write or change C# and need to know if an API/feature is legal in *this* file.
- You hit a build error that only appears in a generator/analyzer project.
- You are reviewing a PR that touches both a generator and the net10 code it feeds.
- You are about to reach for reflection, dynamic codegen, or an un-annotated trim-unsafe call in a net10 library.

## When Not to Use

- The file is under `agent-framework-dotnet-rootsource/` — that is upstream Microsoft source with its own TFM rules; this skill does not describe it.
- The question is about test frameworks/platform, or about NuGet publishing (`use nuget-trusted-publishing`).

## How to tell which group a file is in

Resolve TFM from the **nearest enclosing `.csproj`**, in this order (stop at the first that sets it):

1. The project's own `<TargetFramework>` / `<TargetFrameworks>`.
2. The repo's `Directory.Build.props` (qyl and qyl-tracker-companion set `<TargetFramework>net10.0</TargetFramework>` there as the default; a project that does not override it **is** net10).

```bash
# which TFM does the file I'm editing compile for?
f="src/Foo/Bar.cs"; d=$(dirname "$f")
while [ "$d" != "." ] && [ -z "$(ls "$d"/*.csproj 2>/dev/null)" ]; do d=$(dirname "$d"); done
grep -iE '<TargetFrameworks?>' "$d"/*.csproj || echo "inherits Directory.Build.props default (net10.0)"
```

Decision table:

| What the nearest csproj says | Group | Write code for… |
|---|---|---|
| `<TargetFramework>net10.0</TargetFramework>` or nothing (inherits) | **net10 baseline** | Full modern BCL; keep it AOT/trim-safe |
| `<TargetFramework>netstandard2.0</TargetFramework>` (+ `IsRoslynComponent` / analyzer) | **Roslyn island** | netstandard2.0 BCL only; modern syntax OK; polyfills via the source pack |
| `<TargetFrameworks>net10.0;netstandard2.0</TargetFrameworks>` | **multi-target lib** | The **netstandard2.0** lowest common denominator — it must compile on both |

> ⚠️ **Two false friends.** `Qyl.OpenTelemetry.SemanticConventions.Analyzers.DocsGenerator` *looks* like an analyzer but is **net10.0** (it is an Exe build tool, not loaded into the compiler). `Qyl.AutoInstrumentation` (the runtime lib) is **net10.0** — only its sibling `Qyl.AutoInstrumentation.SourceGenerators` is the island. Don't pattern-match on the name; read the csproj.

## The net10.0 baseline (the other 75)

- `LangVersion=latest`, `Nullable=enable`, `ImplicitUsings=enable` — SDK-owned. Full BCL.
- **AOT/trim-aware.** Avoid unbounded reflection and runtime codegen; annotate or avoid trim-unsafe calls.
- Async/dispose correctness is enforced as **build errors**, not warnings — `qyl/Directory.Build.props` sets `<WarningsAsErrors>CA1816;CA2000;CA2012;CA2016</WarningsAsErrors>` with `EnableNETAnalyzers`. (Each repo's `Directory.Build.props` owns its exact set; check it.) Dispose `IDisposable`s, pass `CancellationToken`, don't fire-and-forget `ValueTask`.

## The netstandard2.0 island (the 7)

- **5 pure Roslyn components** — never run at runtime, AOT/trim analyzers force-disabled (meaningless there, and would trip `WarningsAsErrors`): the two `qyl/internal/*generators*`, the OTel `SourceGeneration` + `Analyzers`, and `Qyl.AutoInstrumentation.SourceGenerators`.
- **2 multi-target libs** (`net10.0;netstandard2.0`) — `Qyl.OpenTelemetry.SemanticConventions` and `.Incubating`. Code here must compile on **both** legs, so it obeys the netstandard2.0 ceiling.
- Modern C# syntax is legal (polyfilled). net10 runtime BCL is not. → [references/netstandard20-cookbook.md](references/netstandard20-cookbook.md).

> 💡 Adding a public `DiagnosticDescriptor`? You **must** add a row to `AnalyzerReleases.Unshipped.md` (RS2000/RS2008 are live). The banned-API analyzer (RS0030) is on. Analyzer packs ship under `analyzers/dotnet/cs/`, not `lib/` (NU5017 suppressed by design). These gates are easy to forget and fail the build.

## Examples — getting the island right

Both blocks below live in a `netstandard2.0` source-generator project (e.g. `Qyl.AutoInstrumentation.SourceGenerators`).

```csharp
// ❌ BAD — net10 runtime BCL inside a netstandard2.0 generator: does NOT compile
var hash = System.HashCode.Combine(name, kind);            // HashCode: netstandard2.1+
ArgumentNullException.ThrowIfNull(symbol);                 // ThrowIf*: net6+
var json = System.Text.Json.JsonSerializer.Serialize(m);  // modern STJ: absent on ns2.0
```

```csharp
// ✅ GOOD — same intent via the polyfills from ANcpLua.Roslyn.Utilities.Sources
var hash = HashCombiner.Combine(name, kind);
Guard.AgainstNull(symbol);
// a generator emits source text — build the string directly; don't serialize at generate time

// modern C# SYNTAX is fine here: LangVersion=latest + polyfilled compiler attributes
public sealed record AttributeModel(string Name, EquatableArray<string> Tags)
{
    public required string SchemaUrl { get; init; }       // 'required' + 'init' compile on ns2.0
}
```

## Common Pitfalls

| Pitfall | Symptom | Fix |
|---|---|---|
| net10 BCL call inside a generator | `CS0103`/`CS1061` only in the `*.SourceGenerators` build | Swap for the polyfill — `HashCode`→`HashCombiner`, `ArgumentNullException.ThrowIfNull`→`Guard`, `System.Text.Json`→hand-rolled/`EquatableArray` (cookbook) |
| Assuming records/`init`/`required` are banned on the island | Over-cautious rewrite to verbose boilerplate | They compile — the source pack ships `IsExternalInit`, `RequiredMemberAttribute`, `CompilerFeatureRequiredAttribute` |
| Editing a multi-target lib with a net10-only API | Builds on the net10 leg, fails the netstandard2.0 leg | Target the netstandard2.0 ceiling; or `#if NET` guard the net10-only branch |
| New analyzer diagnostic, no release-tracking row | `RS2000`/`RS2008` build error | Add the descriptor to `AnalyzerReleases.Unshipped.md` |
| Reflection/codegen in a net10 library | Trim/AOT analyzer warning → error | Annotate (`[RequiresUnreferencedCode]`) or redesign to be trim-safe |

## Verification checklist

Before committing a change in a qyl project, confirm:

- [ ] You resolved the TFM from the **nearest `.csproj`** — not guessed from the folder or assembly name.
- [ ] On `netstandard2.0` (or a `net10.0;netstandard2.0` leg): no net10 runtime BCL — polyfilled equivalents used instead.
- [ ] You did **not** avoid modern C# syntax out of caution — records / `init` / `required` compile on the island.
- [ ] New public `DiagnosticDescriptor` → a row was added to `AnalyzerReleases.Unshipped.md`.
- [ ] On a `net10.0` library: the change stays AOT/trim-safe (no unbounded reflection or runtime codegen) and disposes / passes `CancellationToken` correctly.

## Reference files

- **[references/project-tfm-map.md](references/project-tfm-map.md)** — the exact per-project TFM table for the whole workspace, grouped by bucket, plus the false-friends. **Load when** you need the authoritative TFM of a specific project rather than inferring it.
- **[references/netstandard20-cookbook.md](references/netstandard20-cookbook.md)** — the net10-BCL → netstandard2.0-polyfill substitution table, the allowed-syntax list, and the analyzer/generator gotchas. **Load when** writing or fixing code on the island.

## Related skills

- `nuget-trusted-publishing` — for publishing the NuGet packages these qyl projects produce.
- For test-framework and platform choices in qyl test projects (xUnit v3 on Microsoft.Testing.Platform, TUnit), use the `dotnet-test` skill pack.

## Re-derive the map (when projects change)

```bash
cd ~/RiderProjects/qyl-workspace
for d in qyl Qyl.AutoInstrumentation Qyl.OpenTelemetry.SemanticConventions qyl-dotnet-autoinstrumentation qyl-api-schema qyl-tracker-companion; do
  find "$d" -name '*.csproj' -print0 | xargs -0 grep -lE '<TargetFrameworks?>[^<]*netstandard2\.0' 2>/dev/null
done   # everything else inherits net10.0
```
