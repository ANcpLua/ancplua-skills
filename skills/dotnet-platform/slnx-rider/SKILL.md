---
name: slnx-rider
description: Organize .slnx solutions and make Rider index everything in them. Use when a .slnx or .sln is created, cleaned up or migrated, when MSBuild config files (Directory.Build.props, global.json, nuget.config), docs or loose files don't show in Rider or search, when validating against Slnx.xsd, or when a .sln and .slnx sit side by side.
---

# .slnx organization and Rider indexing

The `.slnx` decides what the solution **contains**; `indexLayout.xml` decides what Rider **indexes**. Fix the right one.

## 1. Run all four null-checks

Don't stop at the first hit; record each verdict. Commands, false alarms, rationale: [references/null-checks.md](references/null-checks.md). FAIL not in its table, or schema disputed: [references/xsd-gaps.md](references/xsd-gaps.md).

a) **Schema:** `xmllint --schema assets/Slnx.xsd <file>.slnx --noout`. PASS closes the branch; FAIL is not proof of a bug.
b) **Both `.sln` and `.slnx`?** Rider opens the `.sln`; delete it once `dotnet build <file>.slnx` passes.
c) **Every `<File Path>` and `<Project Path>`** resolves on disk.
d) **Rider started before the file changed?** Reopen before trusting the UI.

## 2. List the MSBuild config files

Sweep for them recursively, excluding `bin`/`obj`, present the list, and put the ones this repo's build uses in a `<Folder>`. File list, schema rules, what to skip: [references/solution-items.md](references/solution-items.md).

## 3. Make Rider index them

Quit Rider, add each folder or file as `<Path>` (capital P, no wildcards) under `explicitIncludes` in `.idea/.idea.<SolutionName>/.idea/indexLayout.xml`, reopen the `.slnx` directly. Example, pitfalls: [references/rider-indexing.md](references/rider-indexing.md).

## Report back

Say which null-check fired and its evidence: a stale IDE and a malformed file need different fixes, and look alike.
