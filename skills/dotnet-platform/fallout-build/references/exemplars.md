# Fallout build reference

Paths are relative to `<examples>/`, the local examplefalloutbuilds checkout that holds `Fallout/` and `dotnet-library-starter-kit/`.

## Exemplar map

| Feature | Exemplar |
|---|---|
| Build project with exact pins and `PackageDownload` tools | `dotnet-library-starter-kit/templates/Source/Build/_build.csproj` |
| `Configuration` enumeration | `dotnet-library-starter-kit/templates/Source/Build/Configuration.cs` |
| Target chain Restore, Compile, tests, API checks, package scan, Pack with `ReportSummary` | `dotnet-library-starter-kit/templates/Source/Build/Build.cs` |
| Bootstrap that runs the build project with `dotnet run` | `dotnet-library-starter-kit/templates/Source/build.sh` |
| `[GitHubActions]` with `InvokedTargets`, `PublishArtifacts`, concurrency, pull request branches | `Fallout/build/Build.CI.GitHubActions.cs`, `Fallout/docs/website/05-cicd/github-actions.md` |
| PackageGuard target with `.Produces` for SBOM and SARIF | `Fallout/build/Build.PackageGuard.cs` |
| Running a target inside Docker | `Fallout/build/Build.RunTargetInDockerTest.cs` |
| Downloading license files before packing | `Fallout/build/Build.Licenses.cs` |
| `[Parameter]`, `[Secret]`, `.Requires` | `Fallout/docs/website/02-fundamentals/06-parameters.md` |
| Targets, `.Produces`, `OnlyWhen*` | `Fallout/docs/website/02-fundamentals/05-targets.md` |
| `[GitRepository]`, `[Solution]` | `Fallout/docs/website/03-common/05-repository.md`, `Fallout/src/Fallout.Cli/templates/Build.cs` |
| `[GitVersion]` | `Fallout/docs/website/03-common/06-versioning.md` |
| `[NuGetPackage]`, `PackageDownload`, the `Tool` delegate | `Fallout/docs/website/03-common/08-cli-tools.md` |
| `Assert.*` | `Fallout/docs/website/02-fundamentals/14-assertions.md` |
| Workflows beyond the build: cross-platform matrix, docs-only skip, security scan with SARIF, preview and release publishing, preview pruning | `Fallout/.github/workflows/` (`build-cross-platform.yml`, `build-skip.yml`, `security-scan.yml`, `publish-packages-preview.yml`, `publish-packages-release.yml`, `prune-preview-packages.yml`) |
| Repository policy: dependency updates, release notes categories, protected release branches | `Fallout/.github/dependabot.yml`, `Fallout/.github/release.yml`, `Fallout/.github/release-branch-ruleset.json` |
| License policy and build parameters | `Fallout/.packageguard/config.json`, `Fallout/.fallout/parameters.json` |

## Decisions behind the conventions

Fallout's architecture decision records are in `Fallout/docs/adr/`. Read the ones that bear on the change before choosing a pattern:
- ADR-0001 (CD primitives): attributes carry file-shaped configuration, tasks carry API-shaped state.
- ADR-0002 (cross-provider auth and secret conventions) and ADR-0003 (variables and `${...}` substitution).
- ADR-0009 (semver): Fallout stays on semver 10.x, reverting the CalVer and 11.x plans, so pin the 10.x line. It keeps ADR-0007 (cut release branches on demand) and ADR-0008 (no separate experimental branch).
- ADR-0002 (v11 off nuget.org by default): preview builds go to GitHub Packages, nuget.org is opt-in.
- ADR-0010: Fallout collects no telemetry.

Experimental APIs carry `[Experimental("FALLOUTnnn")]`, which is an error until the ID is suppressed with `#pragma warning disable FALLOUTnnn` or `<NoWarn>$(NoWarn);FALLOUTnnn</NoWarn>`. The registry is in `Fallout/docs/experimental-apis.md`. On 29 September 2026 it lists one ID, `FALLOUT001`, for multi-channel publishing through `IPublish` (10.5.x).

## Known breakages

Checked on 28 and 29 September 2026.
- `Fallout.Common` 11.0.1 to 11.0.18 are unlisted on NuGet, because ADR-0009 moved Fallout back to semver 10.x. 10.4.0 is the latest listed release, and the exemplars pin 10.3.49 or 10.4.0. Check listing status with the NuGet registration API, because the flat container index also lists unlisted versions.
- On `Fallout.Common` 11.0.18, `[GitVersion]` fails to parse GitVersion.Tool 6.8.2 output (`CommitsSinceVersionSource` is typed as a string and emitted as a number). Call the tool with `/nofetch /nocache /showvariable FullSemVer` instead.
- On `Fallout.Common` 11.0.18, a settings `.When(...)` condition is a `Func<TSettings, bool>`, not a `bool`.
- No published Fallout package contains `PackageGuardTasks`. It exists only in Fallout's source. Call PackageGuard through `[NuGetPackage("PackageGuard", "PackageGuard.dll")]`, as FluentAssertions' build does.
- `fallout` setup can write the global tool's assembly version (`10.4.0.15`) into `.config/dotnet-tools.json`. The package version is `10.4.0`, and `dotnet tool restore` fails on the other.
- `System.Security.Cryptography.Xml` 10.0.6, a transitive dependency of `Fallout.Common`, carries two high advisories (NU1903). Pin 10.0.12 directly, as the starter kit does.
- macOS ships GNU Make 3.81. A `build` target next to a `build/` folder needs `.PHONY: build`.
- On macOS 27, `hdiutil attach` is deprecated. Use `diskutil image attach --readOnly --nobrowse --mountPoint <dir> <image>` and `diskutil eject <dir>`.

## Docker-built PDF

- Base image `texlive/texlive:latest@sha256:<digest>`. The full scheme needs no `tlmgr` at build time. Assert required packages with `kpsewhich <package>.sty`.
- Deterministic output: pass `SOURCE_DATE_EPOCH` (the last commit time from `git log -1 --format=%ct`) as a build argument and set `FORCE_SOURCE_DATE=1` in the TeX stage. The same commit then gives a byte-identical PDF, and `\today` prints the commit date.
- `DockerBuild` with `--target pdf` and `SetOutput("type=local,dest=artifacts")`, then `Assert.FileExists` and `ReportSummary` with the SHA-256.
- The Dockerfile copies only the files LaTeX reads, so a file in a subfolder needs its own `COPY`.
- Fail the build when the LaTeX log reports undefined citations or references.
- Numbers in the document come from the evidence files through a target that writes a `.tex` data file, so a rebuild regenerates them.
