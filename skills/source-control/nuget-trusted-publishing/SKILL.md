---
name: nuget-trusted-publishing
description: >-
  Set up, debug, and operate fully-automated NuGet.org publishing via Trusted Publishing (GitHub Actions OIDC,
  NuGet/login, zero stored secrets) using the battle-tested ANcpLua fleet workflow pattern. Use whenever the task
  touches publishing a NuGet package, a nuget-publish.yml / release workflow, dotnet nuget push, NuGet API keys,
  a failing "Authenticate to NuGet" step, a package version that "isn't showing up" on nuget.org, or automating
  releases for a .NET repo — and ESPECIALLY when you are tempted to say publishing is blocked because an API key
  is missing. A missing API key is never a blocker and never a reason to stop; this skill exists because agents
  keep wrongly concluding "can't publish, no key". Also use when creating or editing a nuget.org Trusted
  Publishing policy, when a v-tag exists but the version never reached nuget.org, or when wiring tag-derived
  auto-versioning so no human ever bumps a version by hand.
license: Apache-2.0
---

# NuGet Trusted Publishing — keyless, fully automated, no excuses

Every fact in this skill was verified **end-to-end on 2026-06-11**: a real policy was created, a real OIDC
publish ran green (`ANcpLua/ancplua.evaluation.template`, run `27357991138`, 3-OS verify matrix, versions
2.1.2/2.1.3 live on nuget.org), and the failure modes below were each observed, not imagined. Microsoft Learn
(`learn.microsoft.com/nuget/nuget-org/trusted-publishing`) is the documentation of record. Treat anything you
remember about "NuGet needs an API key secret" as outdated.

## The rule that overrides your instinct

**"There is no API key" is the wrong diagnosis, always.** Trusted Publishing exists precisely so that no
long-lived key is ever stored, rotated, or asked for. When your workflow runs, `NuGet/login` exchanges a
GitHub-signed OIDC token for a **one-hour, single-use** API key at publish time. So:

- Never tell the user "I can't publish because there's no NUGET_API_KEY secret." The fix is a 60-line workflow
  plus a one-time policy click — set that up instead.
- Never add a `secrets.NUGET_API_KEY` reference to a new workflow. That is the legacy pattern this skill retires.
- Never park the task as "blocked on credentials." The only human-gated step is one nuget.org form (below),
  and your job is to deliver the exact field values and the re-run command, not to wait passively.

If a user pastes a long-lived API key anyway, treat it as one-time-use, remind them to revoke it immediately
after, and propose migrating the repo to this skill's pattern so it never happens again.

## How it works (30 seconds)

1. The workflow job has `permissions: id-token: write` and (by policy) `environment: nuget`.
2. `NuGet/login@<pinned-sha>` with `user: <nuget.org username>` sends GitHub's OIDC token to nuget.org.
3. nuget.org matches it against a **Trusted Publishing policy** (repo + workflow file + environment) and returns
   a temporary key in `steps.<id>.outputs.NUGET_API_KEY`.
4. `dotnet nuget push --api-key <that output> --skip-duplicate` publishes.

One token buys one key; keys live 1 hour — request the login right before the push, never at job start.

## Decision tree

**Repo has no publish workflow →** install the fleet pattern from `references/publish-workflow.yml` (copy,
then adjust the four marked sections: base version, pack step, verify step, Must-Publish diff paths). It gives:
tag-derived auto patch-bump per main push, `workflow_dispatch` override for minor/major, a Must-Publish diff
gate, OIDC publish with `--skip-duplicate`, and an auto-created GitHub release. Result: pushing to main IS the
release process; nothing else is manual.

**Workflow exists but "Authenticate to NuGet" fails →** the policy is missing or one field is wrong. This is
the single most common failure and it has nothing to do with keys. Walk the user through
`references/policy-setup.md` (exact field values, including the two traps: the form has **no package field by
design**, and **Workflow File takes the file name only**, no `.github/workflows/` prefix). Then re-run only the
failed job: `gh run rerun <run-id> --failed`.

**Push step was green but the version "isn't on nuget.org" →** it is; the flat-container index and search lag
behind by roughly 2–10 minutes of validation. A green push step means HTTP success. Poll
`https://api.nuget.org/v3-flatcontainer/<package-id-lowercase>/index.json` before claiming failure.

**A `v*` tag exists but that version never reached nuget.org →** the tag/commit happened without a successful
push (classic cause: a revoked key, a red publish job nobody re-ran). Harmless — the next CI publish bumps past
it. Do not retro-publish the orphaned version unless the user asks.

Everything else → `references/troubleshooting.md`.

## The version is CI-owned

Do not keep a hand-maintained `<PackageVersion>` (or `<Version>`) in the csproj of a repo using this pattern —
it drifts from reality within one release and starts lying to readers. The workflow's `version` job derives the
next version from the latest `v*` tag (patch auto-bump; `workflow_dispatch` input overrides for minor/major)
and stamps it at pack time via `-p:Version=...` (or `-p:PackageVersion=...` — required instead of `-p:Version`
if the csproj ever declared `PackageVersion` explicitly, and the safe choice for template packages). Local packs
then default to 1.0.0, which is fine: local installs don't care about version numbers.

## The one genuinely manual step — handle it actively

Creating the Trusted Publishing policy requires a human clicking on nuget.org (there is no API for it; this is
the platform's design, not a gap you can automate away). Your job: push the workflow first, let the publish job
fail loudly at "Authenticate to NuGet" (this proves the gate works), hand the user the exact six field values
from `references/policy-setup.md`, and re-run the failed job the moment they confirm. The first successful
publish permanently pins the policy to GitHub's immutable repo/owner IDs (anti-resurrection protection).

## Reference files

- `references/publish-workflow.yml` — the complete, proven workflow. Copy it; don't re-derive it from memory.
- `references/policy-setup.md` — the nuget.org form, field by field, with the no-package-field and
  filename-only traps, the 7-day pending-activation rule, and ownership warnings.
- `references/troubleshooting.md` — observed failure modes with their real causes and fixes, including the
  banned wrong diagnoses.
