# netstandard2.0 island cookbook — what compiles, what doesn't, what to use instead

Loaded by the `qyl-tfm-map` skill when writing or fixing code on the netstandard2.0 island (the source generators, analyzers, and the netstandard2.0 leg of the multi-target OTel libs).

**Verified 2026-06-13** against `ANcpLua.Roslyn.Utilities.Sources` **2.2.26** on disk (`~/.nuget/packages/ancplua.roslyn.utilities.sources/2.2.26/contentFiles/cs`). Every polyfill named below was confirmed present in that package, not assumed. The pack is referenced source-only with `PrivateAssets="all"`, so its types compile into the generator assembly and ship nothing at runtime.

## The one distinction that matters

| | Allowed on the island? | Why |
|---|---|---|
| Modern C# **syntax** (records, `init`, `required`, primary ctors, collection expressions, list/property patterns, file-scoped namespaces, `using` declarations) | ✅ Yes | `LangVersion=latest` applies on netstandard2.0; the compiler-required attributes are polyfilled by the source pack |
| net10 **runtime BCL** (types/methods that didn't exist in netstandard2.0) | ❌ No | The project compiles against the netstandard2.0 reference assemblies — those APIs are simply absent |

> 🚨 **"Old framework therefore old C#" is the wrong mental model. Syntax is current; only the runtime API surface is frozen at netstandard2.0.**

## Compiler-feature attributes — polyfilled, so the syntax just works

These ship in the source pack; do **not** redefine them and do **not** avoid the syntax that needs them:

| Attribute | Unlocks |
|---|---|
| `IsExternalInit` | `init` accessors, `record` positional members |
| `RequiredMemberAttribute`, `SetsRequiredMembersAttribute` | `required` members |
| `CompilerFeatureRequiredAttribute` | `required` / ref-field features the compiler emits |
| `CallerArgumentExpressionAttribute` | `[CallerArgumentExpression]` in guards |
| `DynamicallyAccessedMembersAttribute` (+ `DynamicallyAccessedMemberTypes`) | trim annotations that still parse on netstandard2.0 |

## net10 BCL → netstandard2.0 substitution

Reach for the pack's helper instead of the net10 API:

| You want (net10) | On the island use (from `ANcpLua.Roslyn.Utilities.Sources`) |
|---|---|
| `System.HashCode.Combine(...)` | `HashCombiner` |
| `ArgumentNullException.ThrowIfNull(x)` / `ArgumentException.ThrowIf...` | `Guard.*` (`Guard.AgainstNull`, `Guard.*` numeric/string/collection/path helpers) |
| `Convert.ToBase64String` URL-safe / `Base64Url` | `Base64Url` |
| `ImmutableArray<T>` value equality for generator models | `EquatableArray<T>` (+ `.Linq`) — required for correct incremental caching |
| `[Experimental]` diagnostics | `ExperimentalAttribute` |
| `string.Contains(char)`, `string.Split(char, …)` net-core overloads | use the `string`/`char[]` overloads that exist in netstandard2.0, or the pack's string/format extensions |
| `System.Text.Json` source-gen niceties | hand-roll; generators should emit strings, not depend on STJ at generate time |
| `Span`/`Memory` BCL overloads added after netstandard2.0 | the `System.Memory` types exist, but **not** the BCL methods that take them — check the specific overload |

When a helper you need isn't in the pack, prefer adding it to the pack (it's the user's own `ANcpLua.Roslyn.Utilities.Sources`) over inlining a one-off polyfill — that keeps every generator project consistent.

## Generator / analyzer gotchas (these fail the build, and they're easy to miss)

| Gotcha | Rule |
|---|---|
| Public `DiagnosticDescriptor` with no release-tracking row | Add it to `AnalyzerReleases.Unshipped.md` — `RS2000`/`RS2008` are enforced (move to `Shipped.md` on release) |
| Banned API | `RS0030` (BannedApiAnalyzers) is on; respect `BannedSymbols.txt`. The OTel generator deliberately `NoWarn`s `RS0030` only for the pack's own polyfills |
| Incremental generator correctness | Models flowing through the pipeline must have value equality — use `EquatableArray<T>`, records, or `IEquatable<T>`; never raw `ImmutableArray<T>`/collections as pipeline state |
| AOT/trim/single-file attributes | Force-disabled on the island (`IsAotCompatible=false`, `EnableTrimAnalyzer=false`, etc.) — don't re-enable them; they're meaningless for a compiler plugin and trip `WarningsAsErrors` |
| Packaging | Analyzer/generator DLLs ship under `analyzers/dotnet/cs/`, not `lib/`; `NU5017` is suppressed by design, symbols off |
| The multi-target libs (`SemanticConventions`, `.Incubating`) | A net10-only API must be `#if NET … #else … #endif` guarded, or avoided — the netstandard2.0 leg must still compile |

## Quick self-check before writing island code

- [ ] Is the nearest `.csproj` actually `netstandard2.0` (or the netstandard2.0 leg of a multi-target)? If net10, none of this applies.
- [ ] Am I using a net10 *runtime* API? → substitute from the table.
- [ ] Am I avoiding modern *syntax* out of misplaced caution? → don't; it's polyfilled.
- [ ] New public diagnostic? → release-tracking row added.
- [ ] Generator pipeline state has value equality?
