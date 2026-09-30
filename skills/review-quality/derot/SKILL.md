---
name: derot
description: Audit dependency choices and migration claims against repository manifests, the resolved dependency graph, exact package source, upstream releases, and official vendor documentation. Use when asked why a dependency exists, whether a direct reference is redundant or transitive, whether narrow packages should become a parent/meta package, whether a package is superseded, or whether a proposed dependency migration is actually supported by primary evidence.
---

# Derot Dependency Verification

Verify dependency claims before proposing changes. This distilled skill is evidence-first and proposal-only: it does not create subagents and does not change dependency files unless the user separately asks for implementation.

## Workflow

1. **Resolve scope.** Identify the named packages and tightly coupled companions. Do not expand into unrelated dependencies.
2. **Establish current state.** Read manifests, central version files, project files, lockfiles, and restore output. Record exact versions and every pin.
3. **Inspect the graph.** Use the ecosystem's native dependency graph. For .NET, prefer `dotnet nuget why` when supported and corroborate with assets/lock data.
4. **Inspect exact source.** Read the exact shipped package source for NuGet packages when implementation, package metadata, or shipped API behavior matters (nuget.org's embedded source/symbols, the release tag matching the package version, or a local extraction of the .nupkg). Verify the checkout's version markers match the package version before grounding claims in it.
5. **Read upstream change evidence.** Check the official repository's release, tag, changelog, migration guide, and API surface. For succession claims, require explicit official vendor documentation.
6. **Scan real usage.** Find every relevant call site, wrapper, configuration entry, and documentation claim in the repository.
7. **Refute each finding.** Re-derive it from primary sources and actively search for a missed consumer, compatible overload, retained API, target-framework limitation, or contrary graph edge.
8. **Report.** Separate verified findings from unverified possibilities and changes requiring a product decision.

Read [references/dependency-verification.md](references/dependency-verification.md) for evidence requirements, finding shapes, and the report schema.

## Guardrails

- Never assert package containment, replacement, deprecation, or succession from memory.
- Do not use package naming similarity as evidence.
- Do not recommend removing a direct reference merely because it appears transitively; check whether it deliberately pins a version or exposes APIs used directly.
- Do not recommend a meta package without accounting for additional transitive dependencies.
- Mark incomplete claims `unverified` and name the missing evidence.
- Keep all proposed dependency changes **flagged, not changed** during an audit.
- If the user later requests implementation, recheck the evidence, update all call sites and pins together, then run the repository's build, test, and lint gates.
