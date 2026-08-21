# Dependency verification reference

Load this reference when evaluating a dependency choice or migration claim.

## Finding shapes

### Transitive direct reference

A package is referenced directly even though another dependency brings it transitively.

Required evidence:

- The resolved graph path showing the transitive edge.
- Whether repository code uses the package's API directly.
- Whether the direct reference intentionally pins a different version.

Removal is justified only when the reference adds no required API or version contract.

### Subset versus parent or meta package

Several narrow packages may be replaceable by a family parent/meta package.

Required evidence:

- The candidate parent package's published dependency list.
- The exact narrow packages currently used.
- Additional packages the parent would introduce.
- A concrete clarity, maintenance, or graph-size benefit.

Package-family naming alone is not containment evidence.

### Superseded package

An official successor may replace a currently referenced package.

Required evidence:

- Current official vendor documentation, release notes, or migration guidance explicitly stating replacement or succession.
- Target-framework and platform compatibility.
- Repository call sites affected by the replacement.
- The target package/version and required API rewrites.

Never maintain a hardcoded predecessor-to-successor list.

## Evidence hierarchy

1. Repository manifests, resolved graph, lock/assets data, and build/test output.
2. Exact package source and metadata resolved from the shipped .nupkg or the version-matched upstream tag.
3. Official vendor documentation, releases, tags, changelog, and migration guides.
4. Secondary sources only as discovery leads; verify their claims against sources above.

## Refutation checklist

For every finding, attempt to disprove it:

- Is another version actually resolved?
- Is there a missed project, target framework, or call site?
- Does the allegedly removed API still exist in a compatible overload?
- Does the direct reference enforce a deliberate version boundary?
- Does the proposed parent/meta package add unwanted dependencies?
- Does official guidance describe coexistence rather than replacement?
- Would the proposal fail the repository's build, test, or packaging contract?

If counterevidence exists, reject or weaken the finding. If evidence is incomplete, mark it `unverified`.

## Report schema

For each finding provide:

- `package`
- `current version`
- `shape`: `transitive`, `subset`, `superseded`, or `migration`
- `claim`
- `primary evidence`: graph path, source `file:line`, or official URL
- `refutation attempt`
- `counterevidence`
- `status`: `verified`, `rejected`, `weakened`, or `unverified`
- `recommendation`
- `validation required`

End with a separate **flagged, not changed** list.
