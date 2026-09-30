# Solution items: schema rules and MSBuild config files

## What the schema actually allows

`<Solution>` accepts only `Configurations`, `Project`, `Folder` and `Properties`.
There is **no `<File>` at solution level** — a loose file must live inside a `<Folder>`,
which is why folders exist at all. `Folder/@Name`, `File/@Path` and `Project/@Path` are
all required.

```xml
<Solution>
  <Folder Name="/build/">
    <File Path="Directory.Build.props" />
  </Folder>
</Solution>
```

## List the MSBuild config files explicitly

These belong to no project, so nothing puts them in the solution for you, and they are
exactly the files people edit when a build misbehaves. Sweep for them and give them a
folder:

`Directory.Build.props`, `Directory.Build.targets`, `Directory.Packages.props`,
`global.json`, `nuget.config` / `NuGet.config`, `.editorconfig`, `Version.props`,
`*.nuspec`, `*.globalconfig`

Search recursively and exclude `bin`/`obj` — the nested ones matter most, because a
`tests/Directory.Build.props` silently overrides the root one and is the usual
explanation for "why does it only fail in tests". Case varies between repos
(`nuget.config` vs `NuGet.config`); match what is on disk, since the path is compared
literally on case-sensitive filesystems.

Not every hit belongs in the solution, so present the list before adding it. Config
files under `templates/`, `content/` or a `dotnet new` template root are *payload* —
they configure the generated project, not this one, and pulling them into the solution
makes them look like build inputs they are not. The rule of thumb: add a config file if
it affects how this repo builds, skip it if it ships to someone else.
