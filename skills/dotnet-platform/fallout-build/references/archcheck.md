# Running ArchCheck's Fallout build

Run commands from the repository root containing `ArchCheck/`. Read
`ArchCheck/Makefile` for SDK bootstrap,
`ArchCheck/build/Build.cs` for target behavior, and
`ArchCheck/build/_build.csproj` for build dependencies.
The Makefile runs Fallout through `dotnet run`; a global Fallout installation
is unnecessary. Use the terminal workflow, without Python wrappers.

## Choose the target

| Target | Work and outputs |
| --- | --- |
| `Containers` | Makes Docker available and pulls missing SDK images. On macOS it can install/start OrbStack; Linux requires a working Docker Engine. |
| `Tool` | Depends on `Containers`; publishes the Linux NativeAOT CLI and builds the analyzer into `ArchCheck/artifacts/tool/`. |
| `Analyze` | Default; depends on `Tool`. Infers ownership, restores, builds with the analyzer, and reports each input into `ArchCheck/artifacts/runs/<name>/`. |
| `Spans` | Depends on `Tool`; checks an OTLP JSON file against one input's inference and writes `ArchCheck/artifacts/spans/`. |

Run only the applicable command, sequentially: these targets share logs and
artifact locations.

```sh
make -C ArchCheck ARGS="Tool"
make -C ArchCheck ARGS="Analyze --date 2026-09-29"
```

An empty repository selection means the bundled `samples/Monolith` input, named
`sample` in artifacts. It uses declared ownership from its `.editorconfig`.
Choose the analysis date deliberately and pass `--date`; compare it with
`analysisDate` in `ArchCheck/repositories.json`.
The build's fallback date is independent of that catalogue field.

For a supplied trace file, substitute its actual path:

```sh
make -C ArchCheck ARGS="Spans --traces /absolute/path/otlp.json --date 2026-09-29"
```

`Spans` reuses existing inference when present. If ownership inputs changed,
refresh inference through `Analyze` first. The target accepts one trace file;
the underlying CLI's directory support is a separate interface.

## Execution boundaries

The active local rules prohibit Bitwarden execution and Git history access.
The build rejects explicit Bitwarden selection and excludes it from `all`.
Other catalogue selections still enter `Prepare`/`TryCheckout`, which inspect
commit objects and can fetch, force-checkout, and clean repositories. Consequently,
`--repositories <name>` and `--repositories all` are not executable under the
current history restriction. Use the bundled sample for build verification;
report the blocked checkout path if catalogue execution is requested. Existing
checkout folders do not skip that path.

## Maintain and verify

- Keep bootstrap in `Makefile`, orchestration in `Build.cs`, dependency versions
  in `_build.csproj`/`global.json`, and compiler injection in
  `ArchCheck/build/ArchCheckRun.targets`.
  Keep analysis semantics in the CLI/analyzer sources.
- The tool freshness check watches `src/`, excluding `bin` and `obj`.
  When dependency or build-setting changes outside `src/` require republishing,
  remove only `ArchCheck/artifacts/tool/` and rerun `Tool`.
- `Analyze` replaces its selected input's run directory. Treat its ownership
  configuration, SARIF, reports, and logs as generated outputs: fix their source
  or generator and rerun the affected target.
- Verify target exit status, fresh expected outputs, and
  `ArchCheck/.fallout/temp/build.log`. The CLI is a Linux binary and runs in the
  container; do not try to execute that published binary directly on macOS.
  For analysis completion and result interpretation, follow
  the `archcheck-evaluation` skill before claiming that an input was successfully evaluated.
