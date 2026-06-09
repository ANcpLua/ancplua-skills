# Forgejo API map

Forgejo v15 base path: `/api/v1`.

Use this file for task routing. Use `forgejo-v15-endpoints.md` for the full generated endpoint inventory and Swagger summaries.

## Auth and instance

```text
GET /user
GET /version
GET /settings/api
GET /settings/repository
GET /settings/ui
```

`GET /user` is the first token check. `GET /version` is the cheapest instance check.

## Repository lifecycle

```text
GET /repos/{owner}/{repo}
PATCH /repos/{owner}/{repo}
DELETE /repos/{owner}/{repo}
POST /user/repos
POST /orgs/{org}/repos
POST /org/{org}/repos
POST /admin/users/{username}/repos
POST /repos/migrate
POST /repos/{owner}/{repo}/forks
POST /repos/{owner}/{repo}/transfer
POST /repos/{owner}/{repo}/transfer/accept
POST /repos/{owner}/{repo}/transfer/reject
POST /repos/{owner}/{repo}/mirror-sync
POST /repos/{owner}/{repo}/push_mirrors
GET /repos/{owner}/{repo}/push_mirrors
POST /repos/{owner}/{repo}/push_mirrors-sync
GET /repos/{owner}/{repo}/push_mirrors/{name}
DELETE /repos/{owner}/{repo}/push_mirrors/{name}
POST /repos/{owner}/{repo}/convert
```

Use `private: true` when creating private repositories.

## Git data and contents

```text
GET /repos/{owner}/{repo}/branches
POST /repos/{owner}/{repo}/branches
GET /repos/{owner}/{repo}/branches/{branch}
PATCH /repos/{owner}/{repo}/branches/{branch}
DELETE /repos/{owner}/{repo}/branches/{branch}
GET /repos/{owner}/{repo}/git/refs
GET /repos/{owner}/{repo}/git/refs/{ref}
GET /repos/{owner}/{repo}/commits
GET /repos/{owner}/{repo}/git/commits/{sha}
GET /repos/{owner}/{repo}/git/commits/{sha}.{diffType}
GET /repos/{owner}/{repo}/compare/{basehead}
GET /repos/{owner}/{repo}/contents
GET /repos/{owner}/{repo}/contents/{filepath}
POST /repos/{owner}/{repo}/contents
POST /repos/{owner}/{repo}/contents/{filepath}
PUT /repos/{owner}/{repo}/contents/{filepath}
DELETE /repos/{owner}/{repo}/contents/{filepath}
POST /repos/{owner}/{repo}/diffpatch
GET /repos/{owner}/{repo}/raw/{filepath}
GET /repos/{owner}/{repo}/archive/{archive}
GET /repos/{owner}/{repo}/languages
```

Use Git push for full repo transfer. Use contents or diffpatch endpoints for bot-sized edits.

## Branch protection and access

```text
GET /repos/{owner}/{repo}/branch_protections
POST /repos/{owner}/{repo}/branch_protections
GET /repos/{owner}/{repo}/branch_protections/{name}
PATCH /repos/{owner}/{repo}/branch_protections/{name}
DELETE /repos/{owner}/{repo}/branch_protections/{name}
GET /repos/{owner}/{repo}/collaborators
GET /repos/{owner}/{repo}/collaborators/{collaborator}
PUT /repos/{owner}/{repo}/collaborators/{collaborator}
DELETE /repos/{owner}/{repo}/collaborators/{collaborator}
GET /repos/{owner}/{repo}/collaborators/{collaborator}/permission
GET /repos/{owner}/{repo}/teams
GET /repos/{owner}/{repo}/teams/{team}
PUT /repos/{owner}/{repo}/teams/{team}
DELETE /repos/{owner}/{repo}/teams/{team}
```

## Pull requests and reviews

```text
GET /repos/{owner}/{repo}/pulls
POST /repos/{owner}/{repo}/pulls
GET /repos/{owner}/{repo}/pulls/{index}
PATCH /repos/{owner}/{repo}/pulls/{index}
GET /repos/{owner}/{repo}/pulls/{base}/{head}
GET /repos/{owner}/{repo}/pulls/{index}.{diffType}
GET /repos/{owner}/{repo}/pulls/{index}/files
GET /repos/{owner}/{repo}/pulls/{index}/commits
GET /repos/{owner}/{repo}/pulls/{index}/merge
POST /repos/{owner}/{repo}/pulls/{index}/merge
DELETE /repos/{owner}/{repo}/pulls/{index}/merge
POST /repos/{owner}/{repo}/pulls/{index}/update
POST /repos/{owner}/{repo}/pulls/{index}/requested_reviewers
DELETE /repos/{owner}/{repo}/pulls/{index}/requested_reviewers
GET /repos/{owner}/{repo}/pulls/{index}/reviews
POST /repos/{owner}/{repo}/pulls/{index}/reviews
GET /repos/{owner}/{repo}/pulls/{index}/reviews/{id}
POST /repos/{owner}/{repo}/pulls/{index}/reviews/{id}
DELETE /repos/{owner}/{repo}/pulls/{index}/reviews/{id}
GET /repos/{owner}/{repo}/pulls/{index}/reviews/{id}/comments
POST /repos/{owner}/{repo}/pulls/{index}/reviews/{id}/comments
GET /repos/{owner}/{repo}/pulls/{index}/reviews/{id}/comments/{comment}
DELETE /repos/{owner}/{repo}/pulls/{index}/reviews/{id}/comments/{comment}
POST /repos/{owner}/{repo}/pulls/{index}/reviews/{id}/dismissals
POST /repos/{owner}/{repo}/pulls/{index}/reviews/{id}/undismissals
```

Use pull request diff/files/commits for review input. Use reviews for rich output, issue comments for robust fallback, and statuses for final verdicts.

## Issues and comments

```text
GET /repos/issues/search
GET /repos/{owner}/{repo}/issues
POST /repos/{owner}/{repo}/issues
GET /repos/{owner}/{repo}/issues/{index}
PATCH /repos/{owner}/{repo}/issues/{index}
DELETE /repos/{owner}/{repo}/issues/{index}
GET /repos/{owner}/{repo}/issues/{index}/comments
POST /repos/{owner}/{repo}/issues/{index}/comments
PATCH /repos/{owner}/{repo}/issues/comments/{id}
DELETE /repos/{owner}/{repo}/issues/comments/{id}
GET /repos/{owner}/{repo}/issues/{index}/timeline
GET /repos/{owner}/{repo}/labels
POST /repos/{owner}/{repo}/labels
GET /repos/{owner}/{repo}/milestones
POST /repos/{owner}/{repo}/milestones
```

Pull requests use issue numbers for general comments.

## Commit statuses

```text
POST /repos/{owner}/{repo}/statuses/{sha}
GET /repos/{owner}/{repo}/statuses/{sha}
GET /repos/{owner}/{repo}/commits/{ref}/status
GET /repos/{owner}/{repo}/commits/{ref}/statuses
```

Use statuses for bot verdicts and external job results.

## Actions

```text
GET /repos/{owner}/{repo}/actions/runners
POST /repos/{owner}/{repo}/actions/runners
GET /repos/{owner}/{repo}/actions/runners/registration-token
GET /repos/{owner}/{repo}/actions/runners/{runner_id}
DELETE /repos/{owner}/{repo}/actions/runners/{runner_id}
GET /repos/{owner}/{repo}/actions/runners/jobs
GET /repos/{owner}/{repo}/actions/runs
GET /repos/{owner}/{repo}/actions/runs/{run_id}
GET /repos/{owner}/{repo}/actions/tasks
POST /repos/{owner}/{repo}/actions/workflows/{workflowfilename}/dispatches
GET /repos/{owner}/{repo}/actions/secrets
PUT /repos/{owner}/{repo}/actions/secrets/{secretname}
DELETE /repos/{owner}/{repo}/actions/secrets/{secretname}
GET /repos/{owner}/{repo}/actions/variables
GET /repos/{owner}/{repo}/actions/variables/{variablename}
POST /repos/{owner}/{repo}/actions/variables/{variablename}
PUT /repos/{owner}/{repo}/actions/variables/{variablename}
DELETE /repos/{owner}/{repo}/actions/variables/{variablename}
```

User, organization, and admin runner scopes have parallel endpoint families.

## Releases, packages, webhooks

```text
GET /repos/{owner}/{repo}/releases
POST /repos/{owner}/{repo}/releases
GET /repos/{owner}/{repo}/releases/latest
GET /repos/{owner}/{repo}/releases/tags/{tag}
GET /repos/{owner}/{repo}/releases/{id}
PATCH /repos/{owner}/{repo}/releases/{id}
DELETE /repos/{owner}/{repo}/releases/{id}
GET /repos/{owner}/{repo}/releases/{id}/assets
POST /repos/{owner}/{repo}/releases/{id}/assets
GET /packages/{owner}
GET /packages/{owner}/{type}/{name}/{version}
DELETE /packages/{owner}/{type}/{name}/{version}
GET /packages/{owner}/{type}/{name}/{version}/files
POST /packages/{owner}/{type}/{name}/-/link/{repo_name}
POST /packages/{owner}/{type}/{name}/-/unlink
GET /repos/{owner}/{repo}/hooks
POST /repos/{owner}/{repo}/hooks
GET /repos/{owner}/{repo}/hooks/{id}
PATCH /repos/{owner}/{repo}/hooks/{id}
DELETE /repos/{owner}/{repo}/hooks/{id}
POST /repos/{owner}/{repo}/hooks/{id}/tests
```

`_cargo-index` is only for Cargo registry metadata. It is not needed for qyl CI or PR automation.

## Organization, user, admin

```text
GET /user/repos
GET /user/actions/runners
POST /user/actions/runners
GET /user/actions/runners/registration-token
GET /user/actions/runners/jobs
PUT /user/actions/secrets/{secretname}
DELETE /user/actions/secrets/{secretname}
GET /user/actions/variables
POST /user/actions/variables/{variablename}
PUT /user/actions/variables/{variablename}
GET /orgs/{org}/repos
POST /orgs/{org}/repos
GET /orgs/{org}/actions/runners
POST /orgs/{org}/actions/runners
GET /orgs/{org}/actions/runners/registration-token
GET /orgs/{org}/actions/runners/jobs
GET /admin/actions/runners
POST /admin/actions/runners
GET /admin/actions/runners/registration-token
GET /admin/actions/runners/jobs
GET /admin/users
POST /admin/users
GET /admin/cron
POST /admin/cron/{task}
```
