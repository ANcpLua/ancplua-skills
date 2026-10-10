---
name: gear-1
description: ANcpLua.Roslyn.Utilities compendium read live from the local checkout (helpers, extensions, guards, generator pipeline, black-box test fixtures, polyfills). Use for a reuse campaign over a repo, when writing or refactoring C# in the ANcpLua repos, before hand-rolling a helper, guard, polyfill, pipeline or Roslyn test, or when a reference to these packages breaks.
argument-hint: "[path, project or area to make healthier]"
---

# gear-1: reuse the compendium

The local checkout of `ANcpLua.Roslyn.Utilities` (`ANCPLUA_UTILITIES_ROOT`, default `<repos>/ANcpLua.Roslyn.Utilities` next to the current repo) is the one source of truth for shared .NET helpers. Code gets healthier by **reuse**: each hand-rolled guard, extension, pipeline model, polyfill or test harness becomes a call into the compendium, and whatever the compendium lacks or gets wrong is fixed **upstream** in that repo.

While writing code, take the helper from the index and carry on. A **campaign** (a scope in `$ARGUMENTS`, or a request to clean up a repo) runs every step below from this one invocation; its only stop is the go before anything is pushed.

## Live index

```!
python3 - <<'PY'
import os, re, subprocess, glob, collections
root = os.environ.get("ANCPLUA_UTILITIES_ROOT") or os.path.join(os.path.dirname(os.path.realpath(os.getcwd())), "ANcpLua.Roslyn.Utilities")
if not os.path.isdir(os.path.join(root, "src")):
    print(f"ANcpLua.Roslyn.Utilities not found at {root}; set ANCPLUA_UTILITIES_ROOT."); raise SystemExit
def git(*a):
    try: return subprocess.run(["git", "-C", root, *a], capture_output=True, text=True, timeout=10).stdout.strip()
    except Exception: return ""
tag = next(iter(git("tag", "--sort=-v:refname").splitlines()), "none")
dirty = len([l for l in git("status", "--porcelain").splitlines() if l.strip()])
print(f"repo: {root}")
print(f"head: {git('rev-parse', '--abbrev-ref', 'HEAD')} {git('log', '-1', '--format=%h %cs %s')} | last published: {tag} | uncommitted: {dirty}")

print("\npackages (PackageId [TFMs]):")
for proj in sorted(glob.glob(f"{root}/src/*/*.csproj")):
    x = open(proj).read()
    if re.search(r"<IsPackable>\s*false", x): continue
    pid = (re.search(r"<PackageId>([^<]+)", x) or re.search(r"(^|/)([^/]+)\.csproj$", proj)).group(1 if "<PackageId>" in x else 2)
    tfm = (re.search(r"<TargetFrameworks?>([^<]+)", x) or [None, "?"])[1]
    print(f"- {pid} [{tfm}] -> src/{os.path.basename(os.path.dirname(proj))}")

decl = re.compile(r"^\s*(?:(public|internal|private|file)\s+)?(?:(?:static|sealed|abstract|partial|readonly|ref|unsafe|new)\s+)*(class|struct|record struct|record class|record|interface|enum)\s+(\w+)")
member = re.compile(r"^\s+public\s+(?!class\b|struct\b|record\b|interface\b|enum\b|delegate\b)(?:(?:static|override|virtual|abstract|sealed|readonly|new|async|extern|unsafe|partial|required|const|implicit|explicit)\s+)*(?:[\w.<>\[\],?() ]+?\s+)?(?:operator\s+\S+|(\w+))\s*(?:<[^>]*>)?\s*(\(|\{|=|;)")
NOISE = {"Equals", "GetHashCode", "ToString", "Dispose", "DisposeAsync", "GetEnumerator", "Deconstruct", "MoveNext", "Current",
         "string", "int", "long", "bool", "object", "double", "decimal", "char", "byte"}
def scan(project, skip=()):
    types = collections.OrderedDict()
    base = f"{root}/src/{project}"
    for path in sorted(glob.glob(f"{base}/**/*.cs", recursive=True)):
        rel = os.path.relpath(path, base)
        if "/obj/" in path or "/bin/" in path or any(rel.startswith(s) for s in skip): continue
        lines = open(path, encoding="utf-8", errors="ignore").read().splitlines()
        current = None
        for i, line in enumerate(lines):
            m = decl.match(line)
            if m and not line.startswith("        "):
                vis = m.group(1) or ""
                guarded = any("ANCPLUA_ROSLYN_PUBLIC" in l for l in lines[max(0, i - 6):i])
                if vis == "public" or guarded:
                    current = m.group(3)
                    t = types.setdefault(current, {"files": [], "members": [], "values": []})
                    if rel not in t["files"]: t["files"].append(rel)
                else:
                    current = None
                continue
            if current and line.startswith("    ") and not line.startswith("         "):
                if re.match(rf"^\s+public\s+{current}\s*\(", line): continue
                mm = member.match(line)
                if mm and mm.group(1) and mm.group(1) != current and mm.group(1) not in NOISE:
                    kind = "values" if (re.search(r"\b(const|readonly)\b", line) or mm.group(2) in "=;") and "(" not in line.split(mm.group(1))[0] else "members"
                    bucket = types[current][kind]
                    if mm.group(1) not in bucket: bucket.append(mm.group(1))
    return types
def show(title, project, skip=()):
    types = scan(project, skip)
    print(f"\n{title}: src/{project} ({len(types)} public types; Type [file when not Type.cs]: methods; values)")
    for name, t in types.items():
        files = t["files"]
        if len(files) > 1: where = f" [{os.path.commonprefix(files).rstrip('.')}.*]"
        elif os.path.basename(files[0]) == f"{name}.cs": where = f" [{os.path.dirname(files[0])}/]" if os.path.dirname(files[0]) else ""
        else: where = f" [{files[0]}]"
        parts = []
        if t["members"]: parts.append(", ".join(t["members"]))
        vs = t["values"]
        if vs: parts.append(", ".join(vs) if len(vs) <= 6 else f"{len(vs)} values ({', '.join(vs[:4])}, ...)")
        print(f"- {name}{where}" + (f": {'; '.join(parts)}" if parts else ""))
show("core helpers", "ANcpLua.Roslyn.Utilities", skip=("Polyfills",))
show("test harness and fixtures", "ANcpLua.Roslyn.Utilities.Testing", skip=("Properties",))
show("AOT/trim test harness", "ANcpLua.Roslyn.Utilities.Testing.Aot", skip=("Polyfills",))

pf = sorted(os.path.relpath(p, f"{root}/src/ANcpLua.Roslyn.Utilities/Polyfills") for p in glob.glob(f"{root}/src/ANcpLua.Roslyn.Utilities/Polyfills/**/*.cs", recursive=True))
print(f"\npolyfills (internal, #if-gated; ship in .Polyfills and .Sources): {', '.join(p[:-3] for p in pf)}")
readme = f"{root}/README.md"
if os.path.exists(readme):
    heads = [l.strip("# ").strip() for l in open(readme) if l.startswith("## ") or l.startswith("### ")]
    print(f"\nREADME.md sections: {' | '.join(heads)}")

cwd_root = ""
try: cwd_root = subprocess.run(["git", "rev-parse", "--show-toplevel"], capture_output=True, text=True, timeout=10).stdout.strip()
except Exception: pass
if cwd_root and os.path.realpath(cwd_root) != os.path.realpath(root):
    files = subprocess.run(["git", "-C", cwd_root, "ls-files", "*.csproj", "*.props", "*.targets"], capture_output=True, text=True, timeout=20).stdout.split()
    hits = []
    for f in files:
        try: text = open(os.path.join(cwd_root, f), encoding="utf-8", errors="ignore").read()
        except OSError: continue
        for line in text.splitlines():
            if "ANcpLua.Roslyn.Utilities" in line or "ANcpLua.Analyzers.AotReflection" in line or "ANcpLuaRoslynUtilities" in line:
                hits.append(f"{f}: {line.strip()[:160]}")
    print(f"\nthis repo ({cwd_root}) references:" if hits else f"\nthis repo ({cwd_root}) references none of these packages yet.")
    for h in hits[:40]: print(f"- {h}")
PY
```

The index is rebuilt from the checkout on every call; the source files it names are the contract. When it reports the repo missing, set `ANCPLUA_UTILITIES_ROOT`.

## Campaign

1. **Plan**: the scope is `$ARGUMENTS` (repo, project or area), else the current repo. Write one todo per module (project or feature folder). Each project references the package its kind takes, pinned the way that repo pins versions (central `Directory.Packages.props` / `Version.props` variable):

   | Project | Package |
   |---|---|
   | `netstandard2.0` analyzer, generator, code fix | `ANcpLua.Roslyn.Utilities.Sources` with `PrivateAssets="all"`; `.Polyfills` alongside for newer C# |
   | `net10.0` / `net11.0` app, library, tool | `ANcpLua.Roslyn.Utilities` |
   | tests of generators, analyzers, code fixes, MSBuild/NuGet packaging, web hosts | `ANcpLua.Roslyn.Utilities.Testing` |
   | Native AOT / trim tests | `ANcpLua.Roslyn.Utilities.Testing.Aot` |
   | other `netstandard2.0` code on newer C# | `ANcpLua.Roslyn.Utilities.Polyfills` (ANcpLua.NET.Sdk bans PolySharp) |

2. **Sweep** each module: list every hand-rolled construct and match it against the index. Read the matching helper's source first: its contract (exception type and parameter name, culture, ordering, null handling, laziness) is what the call site keeps. Frequent matches:

   | Hand-rolled | Compendium |
   |---|---|
   | `if (x is null) throw new ArgumentNullException(nameof(x))`, range and emptiness checks | `Guard.NotNull`, `Guard.NotNullOrWhiteSpace`, `Guard.InRange`, ... |
   | `ImmutableArray<T>` / `List<T>` in generator models | `EquatableArray<T>` via `ToEquatableArray` / `CollectAsEquatableArray` |
   | diagnostics threaded by hand through a pipeline | `DiagnosticFlow<T>` + `ReportAndStop` / `ReportAndAddSources` |
   | `RegisterSourceOutput` loops calling `AddSource` | `FileWithName` + `AddSources` |
   | `StringBuilder` with manual indentation or headers | `IndentedStringBuilder`, `GeneratedCodeHelpers` |
   | `ToDisplayString() == "System.Threading.Tasks.Task"` and friends | `IsTaskType`, `IsSpanType`, `IsEnumerableType` (`TypeSymbolExtensions`), `Match.Type()` / `Match.Method()` |
   | `int.TryParse(s, out v)` on the current culture | `TryParseInt32` and siblings (`TryExtensions`, invariant culture) |
   | `TryGetValue`, then insert | `GetOrAdd` / `GetOrInsert` (`DictionaryExtensions`) |
   | throttled `Task.WhenAll(items.Select(...))` | `SelectParallel` / `SelectParallelOrdered` |
   | timestamped dictionary cache | `ExpiringCache<TKey,TValue>` |
   | `CSharpGeneratorDriver` / `CSharpCompilation` setup in tests | `Test<TGenerator>.Run`, `GeneratorTestHelper.RunGenerator<T>`, `GeneratorResult` (`IsClean`, `IsCached`, `Produces`) |
   | `Process.Start("dotnet", ...)` in tests | `ProjectBuilder` (`NetSdkVersion.Ambient` for the installed SDK), `BuildResultAssertions` |

3. **Replace**: tests stay unchanged and green; non-test lines go down.
4. **Upstream** what the compendium should own: a general helper with no match, or a reference that fails (CS0121 against the BCL or Roslyn, a type defined twice, a TFM or restore error, a Roslyn version floor). Every upstream fix lands with a regression test that goes **red** on the old code and **green** on the fix, shaped like `PublicSurfaceTests` (API surface) or `PackageConsumptionTests` (packs from the checkout, builds a consumer through `ProjectBuilder`). The consumer keeps a plain package reference.
5. **Skeptic**: hand each module's diff and the helper sources to an `ancplua-lean-proof:skeptic` subagent; what it demonstrates (a changed contract, a missed construct) goes back into step 2.
6. **Verify**: build and test every touched project through its Fallout target when the repo has `build/Build.cs`, else `dotnet build` / `dotnet test`. The utilities repo runs in CI mode (`CI=true`, warnings are errors).
7. **Deliver**: one branch and commit per module, stacked where files overlap, ready as PRs. Push, PR and merge wait for the user's go.
8. **Report** the numbers: modules, constructs replaced, constructs left and why, upstream fixes with their red/green tests, non-test lines ±, tests ±, build status, and what the campaign did not check.

Done when every module's todo is closed by its evidence and the report is out.

## Patterns

- **Generator shape**: `ForAttributeWithMetadataName` → extractor returning `DiagnosticFlow<Model>` → `ReportAndStop` → emitter returning `FileWithName` → `CollectAsEquatableArray` → `AddSources`. Exemplars: `src/ANcpLua.ExtensibleEnumMirror` (`Extraction/`, `Models/`, `Generation/`, `DiagnosticDescriptors.cs`) and `src/ANcpLua.AotReflection`; tests in `tests/ANcpLua.Roslyn.Utilities.ExtensibleEnumMirror.Tests`.
- **Closed sets**: C# 15 `union` (`public union Pet(Cat, Dog);`) with an exhaustive `switch`; on `netstandard2.0` the `UnionAttribute` / `IUnion` polyfills make it compile.
- **Black-box tests**: drive the generator, analyzer or whole project from outside (`Test<TGenerator>`, `AnalyzerTest<TAnalyzer>`, `CodeFixTest<TAnalyzer,TCodeFix>`, `ProjectBuilder`, `KestrelTestBase<TProgram>`) and assert on output, diagnostics and cache hits.

## Traps

- `Descendants()` / `DescendantsAndSelf()` on `IOperation` come from Roslyn (`using Microsoft.CodeAnalysis.Operations;`); the compendium adds `DescendantsOfType<T>` and `ContainsOperation<T>` on top.
- LINQ `DistinctBy`, `SkipLast`, `TakeLast` come from `System.Linq`; on `netstandard2.0` the Linq polyfill supplies them.
- `OperationExtensions`, `SyntaxExtensions` and `TypedConstantExtensions` share class names with Roslyn's: call their members as extensions, not class-qualified.
- Up to v2.2.46, `.Sources` + `.Polyfills` together fail to compile, every `Inject*=false` switch is a no-op, and the three LINQ methods and the two `Descendants` methods are ambiguous (CS0121). A consumer on such a version moves past it.

## Local packing

- `dotnet pack <utilities repo>/ANcpLua.Roslyn.Utilities.slnx -c Release -o <scratch feed> -p:VersionPrefix=0.0.0 -p:VersionSuffix=<label>` needs nothing beyond the SDK. Consume it the way `PackageConsumptionTests` does: a `nuget.config` with the feed plus nuget.org, a throwaway `globalPackagesFolder`, and the machine cache as fallback.
- Before repacking the same version, run `dotnet build-server shutdown`; running MSBuild nodes keep serving the old `.targets`.
