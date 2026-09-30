# The nuget.org Trusted Publishing policy — field by field

Verified against the live nuget.org UI and `learn.microsoft.com/nuget/nuget-org/trusted-publishing`
on 2026-06-11 (a policy was created and a publish ran green the same day). This is the **one step a human
must click** — there is no nuget.org API for policy creation. Hand the user this table filled in for their
repo, then re-run the failed publish job (`gh run rerun <run-id> --failed`) the moment they confirm.

Path: nuget.org → click your username → **Trusted Publishing** → **Create**.

| Form field | What to enter | Trap to avoid |
|---|---|---|
| Policy Name | Any label; convention: the package id | It's only a display label — the red "Name is required" is the only validation. |
| Package Owner | The nuget.org user/org that owns the packages (dropdown) | — |
| Repository Owner | The GitHub org/user, e.g. `ANcpLua` | Case-insensitive. |
| Repository | The GitHub repo name, e.g. `ancplua.evaluation.template` | Repo NAME only, not owner/name, not a URL. |
| Workflow File | `nuget-publish.yml` | **File name only** — the docs explicitly say do not include the `.github/workflows/` path. |
| Environment | `nuget` (or empty) | Must match the workflow job's `environment:` exactly; leave empty only if the job has none. |

## There is no package field — that is by design

Agents (and humans) look for a "Package" box and conclude the form is broken. It is not. Per the docs:
*"The policy will apply to all packages owned by the selected owner."* The security boundary is the
repo + workflow (+ environment) pair, not the package id. One policy per repo is the norm; a repo's
workflow may publish several packages under the same owner.

## Activation lifecycle

- Policies can start as **temporarily active for 7 days** (typical for private repos). The first successful
  publish provides GitHub's permanent numeric repo/owner IDs and pins the policy **permanently** — this is
  anti-resurrection protection (delete repo → recreate same name → can no longer impersonate). The 7-day
  window can be restarted from the UI at any time if it lapses.
- After the first publish, the Manage view shows the pinned IDs (e.g. `Repository Owner: ANcpLua #124206820`).
- Ownership warnings: a policy goes inactive if its creating user leaves the owning org (reactivates when
  re-added) or the org is locked/deleted.

## What the workflow must provide to match

```yaml
jobs:
  publish:
    environment: nuget        # must equal the policy's Environment field
    permissions:
      id-token: write         # the OIDC token; without it, login fails regardless of policy
    steps:
      - id: nuget-login
        uses: NuGet/login@8d196754b4036150537f80ac539e15c2f1028841 # v1
        with:
          user: <nuget.org username>   # the PACKAGE owner's username, not the GitHub owner
```

`NuGet/login` outputs the temporary key as `steps.nuget-login.outputs.NUGET_API_KEY` — valid **1 hour**,
single use per OIDC token. Request it immediately before the push step, never earlier in a long job.
