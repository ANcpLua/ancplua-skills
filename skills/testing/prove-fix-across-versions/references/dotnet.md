# .NET recipes

Commands that worked for the red/green loop on a .NET repository. Replace the
angle-bracket placeholders.

## Scratch copy pinned to OLD, one test isolated

```bash
R=<repo root>; S=/tmp/oldproof; P="<project folder>"; T=<TestFileWithoutExtension>
rm -rf $S && mkdir -p $S
cp $R/Directory.Build.props $S/            # plus .targets / Directory.Packages.props if present
cp -R "$R/$P" $S/                          # include sibling projects it references
sed -i '' 's/Version="<NEW>"/Version="<OLD>"/g' "$S/$P/<proj>.csproj"
for f in <NewTestA> <NewTestB> <NewTestC>; do [ "$f" = "$T" ] || rm "$S/$P/$f.cs"; done
dotnet build "$S/$P/<proj>.csproj" 2>&1 | grep -E " (error|warning) " \
  | sed -E 's/.*: (error|warning) ([A-Z0-9]+): (.{0,120}).*/\1 \2: \3/' | sort | uniq -c | sort -rn
dotnet run --no-build --project "$S/$P/<proj>.csproj"
rm -rf $S
```

With central package management, pin through `Directory.Packages.props` in the copy.
`sed -i ''` is the BSD/macOS form; on GNU use `sed -i`.

When a build breaks with many errors, look for a `CS8785` (generator failed) or
`AD0001` (analyzer crashed) warning. That one diagnostic is the cause; the rest is
fallout.

## Reading MSBuild state

To see items after targets have run, without compiling:

```bash
dotnet msbuild <proj> -t:Compile -p:SkipCompilerExecution=true -p:ProvideCommandLineArgs=true \
  -getItem:ReferencePath -getItem:ReferencePathWithRefAssemblies -getItem:CscCommandLineArgs
```

To simulate what an IDE's design-time build sees, add `-p:DesignTimeBuild=true
-p:BuildProjectReferences=false` and query `-getItem:ProjectReference` for its
metadata.

## What an editor sees: a Roslyn workspace probe

`dotnet build` answers what the compiler sees. The C# language server and OmniSharp
load projects through `MSBuildWorkspace`. To check an editor-only error, load the
project the same way:

```xml
<PackageReference Include="Microsoft.Build.Locator" Version="1.11.2" />
<PackageReference Include="Microsoft.CodeAnalysis.Workspaces.MSBuild" Version="<current>" />
<PackageReference Include="Microsoft.CodeAnalysis.CSharp.Workspaces" Version="<current>" />
```

```csharp
MSBuildLocator.RegisterDefaults();
using var workspace = MSBuildWorkspace.Create();
var project = await workspace.OpenProjectAsync(args[0]);
foreach (var r in project.MetadataReferences) Console.WriteLine($"METAREF {r.Display}");
foreach (var r in project.ProjectReferences)
    Console.WriteLine($"PROJREF {workspace.CurrentSolution.GetProject(r.ProjectId)?.Name}");
var compilation = await project.GetCompilationAsync();
foreach (var d in compilation!.GetDiagnostics().Where(d => d.Severity == DiagnosticSeverity.Error))
    Console.WriteLine($"{d.Id} {d.Location.GetLineSpan().StartLinePosition}: {d.GetMessage()}");
```

- Without `Microsoft.CodeAnalysis.CSharp.Workspaces`, opening a project fails with
  "the language 'C#' is not supported".
- Use a current Roslyn. An older one cannot parse newer language features, such as
  C# 14 `extension` blocks that source generators emit, and reports parse errors
  (`CS1513`, `CS1520`) that are not real. Run the probe on NEW as the control.
- Print the references (`METAREF` / `PROJREF`) before you name a cause. The error
  shows the symptom; the reference list shows the mechanism.

## A red/green test that drives MSBuild

A test can run `dotnet msbuild` on its own project to assert build metadata. Two
rules make it stable:

- Mark the class `[NotInParallel]`, because each run rewrites that project's `obj/`.
- Set `MSBUILDUSESERVER=0` and pass `-nodeReuse:false`, so no MSBuild process
  outlives the test holding task assemblies.

Find the project from the test's source with `[CallerFilePath]` and
`Directory.GetFiles(dir, "*.csproj").Single()`, which avoids hard-coding a
versioned name.
