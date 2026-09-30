# Forgejo Actions runner

## Model

Forgejo queues jobs. Runners execute jobs. A run stays waiting until a runner with matching labels is online.

Workflow files:

```text
.forgejo/workflows/*.yml
.forgejo/workflows/*.yaml
```

Fallback to `.github/workflows` can exist, but direct Forgejo setup should use `.forgejo/workflows`.

## Runner scopes

```text
GET /admin/actions/runners
GET /admin/actions/runners/registration-token
GET /orgs/{org}/actions/runners
GET /orgs/{org}/actions/runners/registration-token
GET /user/actions/runners
GET /user/actions/runners/registration-token
GET /repos/{owner}/{repo}/actions/runners
GET /repos/{owner}/{repo}/actions/runners/registration-token
```

Use repository scope for one repo, user scope for all repos owned by a user, organization scope for org repos, admin scope for the instance.

## Labels

Label format:

```text
<label-name>:<label-type>://<default-image>
```

Common labels:

```text
ubuntu-latest:docker://ghcr.io/catthehacker/ubuntu:act-22.04
node22:docker://docker.io/library/node:22-bookworm
host:host://-
```

A job with `runs-on: ubuntu-latest` requires a runner label named `ubuntu-latest`.

## Run and task APIs

```text
GET /repos/{owner}/{repo}/actions/runs
GET /repos/{owner}/{repo}/actions/runs/{run_id}
GET /repos/{owner}/{repo}/actions/tasks
GET /repos/{owner}/{repo}/actions/runners/jobs
POST /repos/{owner}/{repo}/actions/workflows/{workflowfilename}/dispatches
```

Dispatch payload shape is checked in Swagger. Typical body:

```json
{
  "ref": "main",
  "inputs": {}
}
```

## Secrets and variables

```text
GET /repos/{owner}/{repo}/actions/secrets
PUT /repos/{owner}/{repo}/actions/secrets/{secretname}
DELETE /repos/{owner}/{repo}/actions/secrets/{secretname}
GET /repos/{owner}/{repo}/actions/variables
GET /repos/{owner}/{repo}/actions/variables/{variablename}
POST /repos/{owner}/{repo}/actions/variables/{variablename}
PUT /repos/{owner}/{repo}/actions/variables/{variablename}
DELETE /repos/{owner}/{repo}/actions/variables/{variablename}
```

Secrets are for credentials. Variables are for non-secret configuration.

## Safe probes

```bash
curl -fsSL -H "Authorization: token $FORGEJO_TOKEN" "$FORGEJO/api/v1/user"
curl -fsSL -H "Authorization: token $FORGEJO_TOKEN" "$FORGEJO/api/v1/repos/$OWNER/$REPO/actions/runners"
curl -fsSL -H "Authorization: token $FORGEJO_TOKEN" "$FORGEJO/api/v1/repos/$OWNER/$REPO/actions/runs"
curl -fsSL -H "Authorization: token $FORGEJO_TOKEN" "$FORGEJO/api/v1/repos/$OWNER/$REPO/actions/tasks"
```
