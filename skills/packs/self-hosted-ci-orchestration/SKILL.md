---
name: self-hosted-ci-orchestration
description: Use when driving a self-hosted CI runner to a green verdict — bringing an offline/paused runner (and the VM or container engine it lives in) online, draining workflow runs that are queued only because the runner is down, taking a single status snapshot of the result, then tearing the runner and any leaked test containers back down. Use for "get CI green", "the runner is offline", "CI is queued and not starting", "bring the VM up for CI", a self-hosted job that never picks up, or "ci up / ci down". Especially use it before concluding CI is blocked because a runner or VM is stopped — a stopped self-hosted runner is a routine bring-up, never a blocker.
metadata:
  short-description: Bring a self-hosted CI runner up, drain queued runs, report, tear down
---

# Self-Hosted CI Orchestration

Operate a self-hosted CI runner that is kept **stopped while idle** (to spare the host) and brought up only to verify a push. The job is a closed loop — bring it up, let the already-queued runs drain, read the verdict once, put it back to sleep — not a babysitting session.

## The loop

```
status  →  up  →  drain  →  snapshot  →  down + reap
```

1. **status** — read runner + engine state *without waking anything*.
2. **up** — start the VM/engine + runner, wait until it registers online.
3. **drain** — the push already enqueued the runs; they were blocked only on the offline runner. Once it is online they pick up on their own.
4. **snapshot** — read the run conclusions **once** they finish.
5. **down + reap** — stop the runner/VM and reap leaked test containers.

## Rules

- **Read state wake-safe first.** A "is the runner up?" check must not itself wake a stopped VM or relaunch a container engine. Query the forge's runner API (`gh api repos/{owner}/{repo}/actions/runners`) and check the engine's host process — never run the engine/VM CLI (`orb`, `docker`, `limactl`, …) *purely to look*, because that auto-starts it. Save those CLIs for real bring-up/teardown work.
- **A stopped runner is never a blocker.** If a self-hosted job is `queued` and not starting, the cause is almost always "runner offline" — bring it up; do not report CI as blocked, and never conclude the change "can't be verified."
- **Bring up only what the run needs.** Start the one runner/VM the queued jobs target. Leave unrelated runners/VMs stopped.
- **Drain, don't re-trigger.** A push that landed while the runner was down leaves runs `queued`. Bringing the runner online drains them — do **not** re-push or re-dispatch to "kick" CI; that just stacks duplicate runs (forge concurrency then cancels the older ones, which is noise, not a failure).
- **One snapshot, never a live watch.** Poll the run list at a sane interval (or background a waiter that re-invokes you on completion). Do not hold a blocking `--watch` stream open for the whole run — it burns the session for no added signal.
- **Always tear down, even on failure.** Wrap bring-up so teardown + reap run whether the verify passed, failed, or was interrupted (the Ryuk pattern). A runner left online and containers left leaked are the real harm, not a red run.

## Driving it through a control tool

Prefer a single idempotent control tool over ad-hoc `orb`/`docker`/runner commands. The canonical verb-set:

| verb | does | wake-safe? |
|------|------|------------|
| `status` | runner + engine state + leaked-container count | **yes** |
| `up`     | start VM/engine + runner, wait until online | no (real work) |
| `down`   | reap leaked containers (scoped), stop VM/engine | no |
| `reset`  | scoped self-heal for a wedged/lagging host (reap + bounce the runner) | no |
| `run <cmd…>` | up → run → **always** down + reap (survives failure/Ctrl-C) | no |

Keep the tool **idempotent** (an `up` when already up is a no-op) and **agent-owned**: extend it only with scoped, reversible verbs that are safe by construction. The tool — not this skill — owns the machine-specific names (VM id, runner labels, paths); this skill owns the discipline.

## Reaping is scoped — never blanket

Test containers (Testcontainers, ephemeral fixtures) can leak when a run is killed. Reap them on teardown, but **only by their owning label** (e.g. `label=org.testcontainers`) scoped to the CI VM/engine. Never run a blanket `prune`, and **never touch named volumes** — those hold real data. A reap that can delete anything outside the CI scope is a defect.

## Two edges that need a human

Everything above is routine and pre-authorizable. Stop and get explicit sign-off only for:

1. **Runner topology / repo visibility** — changing the workflow→runner mapping, switching to forge-hosted runners, or flipping a repo public. A public repo runs fork-PR code on your self-hosted host: a real blast-radius change.
2. **Deleting anything outside the test-container label** — named volumes, other engines' containers, host paths. That is data loss, not cleanup.

## Anti-patterns

- ❌ "CI can't run, the runner/VM is down." → bring it up; that's the task, not a wall.
- ❌ Running the engine CLI just to check status. → use the wake-safe status path.
- ❌ Re-pushing to force CI. → the runs are already queued; drain them.
- ❌ Leaving the runner online "in case." → tear it down; idle cost is the whole reason it sleeps.
- ❌ `docker system prune` / deleting named volumes to "clean up." → reap by label, scoped, only.

## Configuration (names only — never commit values)

- Repository: the forge default (`gh repo set-default`) or an explicit `-R {owner}/{repo}`.
- Control tool: a project-local executable on `PATH` exposing the verb-set above.
- Auth: a forge token via the environment variable your forge documents (e.g. `GH_TOKEN`) — never inline a token.

Machine-, VM-, and repo-specific topology (runner ids, labels, recreation steps) belongs in a **project-local** skill or the control tool itself, not in this portable skill.
