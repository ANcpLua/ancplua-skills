# Pinning

Every version is exact and committed:
- SDK: `global.json` with an exact `version` and `"rollForward": "disable"`.
- Build packages: exact `PackageReference` versions, with `Fallout.Common` on the 10.x line (ADR-0009, currently `10.4.0`), plus `RestorePackagesWithLockFile` and `RestoreLockedMode` with a committed `packages.lock.json`.
- Tools: `<PackageDownload Include="GitVersion.Tool" Version="[6.8.2]" />` plus a `[NuGetPackage("Id", "tool.dll", Framework = "net10.0")] readonly Tool ...;` field, called as a delegate.
- Global tool: when the workflow runs `dotnet tool restore` and then `dotnet fallout`, `.config/dotnet-tools.json` pins `fallout.globaltool`. The starter kit's `build.sh` runs the build project with `dotnet run` instead and needs no global tool.
- Container images by digest (`image@sha256:...`), and GitHub actions by commit SHA with the version as a trailing comment.
