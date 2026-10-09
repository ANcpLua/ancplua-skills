# Drift

A merge shows textual conflicts. **Drift** is a change on main that the PR's design
contradicts while the merge stays clean.

## Look

```bash
git fetch upstream main
git merge --no-commit --no-ff upstream/main        # textual conflicts
base=$(git merge-base HEAD upstream/main)
git diff "$base" upstream/main -- <files the PR touches>
git diff "$base" upstream/main | grep -n '^+.*<type or function the PR changes>'
```

Read every hit for one of three things:

| On main since the base | Means |
|---|---|
| A new caller of the code the PR changes | The PR's behaviour now applies to that caller. Check whether it relies on the old one. |
| A new test asserting the old behaviour | A maintainer wrote down a contract the PR breaks. |
| A fix, fixture or option for the same problem | Reuse it, or the PR is no longer needed. |

## Example

open-telemetry/weaver#1598 added an existence check to a shared path type. While it
waited, main started passing glob patterns through that type and gained a test that
resolves a folder which does not exist. The merge conflicted only in the changelog;
the check would have rejected both.

## When drift is found

Move the change to where it still fits (step 4), then probe the new place: a second
placement can drift too. In the example, a check one layer up failed a dependency
that main serves from a cache, and only a probe showed it.
