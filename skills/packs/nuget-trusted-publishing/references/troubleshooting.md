# Troubleshooting — observed failure modes, real causes, banned wrong diagnoses

Every entry below was observed live on 2026-06-11 in `ANcpLua/ancplua.evaluation.template`
(runs 27338352276 and 27357991138), not theorized. Read the matching entry BEFORE concluding anything.

## "Authenticate to NuGet" step fails

**Real cause:** no Trusted Publishing policy matches the OIDC token — the policy doesn't exist yet, or one
field mismatches (most often: Workflow File entered with the `.github/workflows/` prefix, or the workflow
job's `environment:` doesn't equal the policy's Environment field, or `permissions: id-token: write` is
missing from the job).

**Fix:** create/correct the policy per `policy-setup.md`, then `gh run rerun <run-id> --failed`. The
artifacts from the green verify job are reused; nothing rebuilds.

**Banned diagnosis:** "the NUGET_API_KEY secret is missing." There is no such secret in this pattern, and
adding one is a regression to the legacy model. Observed proof: the exact same run went from red login to
fully published simply by creating the policy and re-running — zero workflow changes, zero secrets.

## Push step green, but the version doesn't show on nuget.org

**Real cause:** post-push validation + indexing lag. A green `dotnet nuget push` means HTTP success; the
flat-container index (`https://api.nuget.org/v3-flatcontainer/<package-id-lowercase>/index.json`) catches up
in ~2–10 minutes; search and the website can lag further.

**Fix:** poll the flat-container URL. Observed: 2.1.2 pushed at T+0 was absent from the index at T+2min and
present at T+6min.

**Banned diagnosis:** "the publish failed" / re-pushing in a panic. `--skip-duplicate` makes an accidental
re-push harmless, but the right move is to wait and poll.

## A v-tag exists in git but that version never reached nuget.org

**Real cause:** the tag/commit was created without a successful push behind it — e.g. a human or agent
tagged locally while the publish path was broken, or a legacy key had been revoked. Observed: `v2.1.1`
existed in git while nuget.org showed only `..., 2.1.0, 2.1.2`.

**Fix:** nothing. The version job auto-bumps PAST the orphaned tag on the next publish (it derives from the
latest tag, so the gap self-heals). Only retro-publish if the user explicitly wants that exact version.

## NuGet rejects the push with 409 / "version already exists"

**Real cause:** that exact version was published before (NuGet versions are immutable; re-pushing is
forbidden by the registry). Happens when re-running an old run whose computed version already shipped.

**Fix:** `--skip-duplicate` (already in the fleet workflow) turns this into a green no-op. If the content
actually changed, the fix is a new version — i.e. just push to main again.

## Legacy long-lived key warnings

`dotnet nuget push` may warn "Your API key expires in N days" when a legacy key is used. With Trusted
Publishing this warning disappears entirely — temporary keys live 1 hour by design. If a user hands you a
long-lived key for a one-off push: use it once, never echo or commit it, and remind them to revoke it
immediately afterwards (assume it is burned the moment it touched a chat or a shell history).

## Local `dotnet pack` produces version 1.0.0

**Not a bug.** The csproj intentionally carries no `<PackageVersion>` — the version is CI-owned (tag-derived).
Local packs are for local install testing, where the version number is irrelevant. Do not "fix" this by
re-adding a hand-maintained version; that reintroduces drift (observed: csproj said 2.1.1 while nuget.org
was at 2.1.2 within a day of hand-maintenance).

## Multi-OS verify notes

- Set `defaults.run.shell: bash` on matrix jobs — the Windows runner defaults to pwsh and will break
  bash-isms silently otherwise. `$RUNNER_TEMP` paths work fine under Git Bash on Windows.
- Runner labels rotate (observed annotation: `windows-latest` redirecting to `windows-2025-vs2026`); the
  `-latest` labels stay valid — no action needed on such notices.

## When the user asks "can you automate publishing without an API key?"

The answer is an unqualified **yes — that is the default**, not a workaround. Set up the fleet workflow +
policy. The only thing OIDC cannot do is click the nuget.org policy form; deliver the field values and
re-run after the click.
