# Setup and manual probing

- Detect the stack first: `*.sln`/`*.csproj` means C#/.NET (Stryker.NET: `dotnet tool install -g dotnet-stryker`, then `dotnet stryker --project <proj>`); `package.json` + `tsconfig.json` means TypeScript (StrykerJS). Both present: each part with its own toolchain.
- Mutate in an isolated git worktree: mutation runs leave build litter and must not race other work.
- Time-box the tool: if Stryker will not run on this stack version within ~10 minutes of setup effort, fall back to manual mutation probing. Pick ~15 high-value sites (boundary comparisons, merge/aggregation logic, epsilon guards, parser branches), apply one mutant at a time (flip an operator, off-by-one a boundary, swap Max/Min, drop a guard), run the suite, revert, record survivors.
