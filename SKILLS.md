# Skills Registry

> Auto-generated from `skills-registry.yaml` - Do not edit directly

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      AI-AGNOSTIC SKILL PACK INDEX                           │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────┐   ┌─────────────┐   ┌─────────────┐                       │
│  │   Global    │ → │   Domain    │ → │   Session   │                       │
│  │   Skills    │   │   Skills    │   │   Skills    │                       │
│  └─────────────┘   └─────────────┘   └─────────────┘                       │
│        ↓                 ↓                 ↓                                │
│   [BASELINE]        [PROJECT-SCOPED]   [RUNTIME-LOADED]                    │
│   Doc routing       MCP/Web/etc.       Task-specific                       │
│   Always available  Per-domain         On-demand activation                │
│                                                                             │
│  LOADING: Stateless. Each session = fresh parse + merge by priority.       │
│  WEIGHT: Session > Domain > Global (later overrides earlier)               │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Quick Stats

| Scope | Active | Total |
|-------|--------|-------|
| Global | 2 | 2 |
| Domain | 8 | 8 |
| Session | 2 | 2 |

---

## Contents

<details open>
<summary>Table of Contents</summary>

- **Global Skills (Always Loaded)**
  - [D Documentation Grounding](#documentation-grounding) (2)
    - [Microsoft](#microsoft) (2)

- **Domain Skills (Project-Scoped)**
  - [M Model Context Protocol](#model-context-protocol) (1)
    - [.NET](#.net) (1)
  - [S Source Control Platforms](#source-control-platforms) (2)
  - [F Frontend UI](#frontend-ui) (1)
    - [React](#react) (1)
  - [A Architecture Diagramming](#architecture-diagramming) (1)
  - [N .NET Platform](#.net-platform) (1)
  - [A .NET AI & Agent SDKs](#.net-ai--agent-sdks) (1)
  - [C CI Automation](#ci-automation) (1)

- **Session Skills (On-Demand)**
  - [Q Review & Quality](#review--quality) (1)
  - [P Prompt Engineering](#prompt-engineering) (1)

</details>

---

## 🌍 Global Skills

<details open>
<summary><h3>D Documentation Grounding</h3></summary>

> Skills that route work toward authoritative documentation, source, and freshness checks before answering from memory.

#### Microsoft

**`Microsoft-First Research`** &nbsp; `microsoft-first-research` &nbsp; 👆 Manual &nbsp; P1

Routing skill that biases substantive Microsoft-shaped work toward Microsoft Learn, source checkouts, and current first-party documentation before answering from memory.

<details>
<summary>Capabilities</summary>

- `microsoft_grounding`
- `research_routing`
- `docs_first`
- `api_freshness`

</details>
> **Path:** `skills/packs/microsoft-first-research`
> **License:** `Apache-2.0 as declared in SKILL.md`
> **Compatibility:** Portable routing skill; depends on the consuming agent having some Microsoft Learn/doc lookup capability.
> **Trigger:** `microsoft, azure, dotnet, foundry, agent framework, copilot studio, sdk docs, current api`


**`Microsoft Learn Grounding`** &nbsp; `microsoft-learn-grounding` &nbsp; 👆 Manual &nbsp; P2

Operating guide for Microsoft Learn grounding: search/fetch/code-sample retrieval, maxTokenBudget, freshness checks, daily refresh behavior, and limitations of the public docs surface.

<details>
<summary>Capabilities</summary>

- `microsoft_learn`
- `documentation_search`
- `freshness_checks`
- `source_links`

</details>
> **Path:** `skills/packs/microsoft-learn-grounding`
> **License:** `Apache-2.0 as declared in SKILL.md`
> **Compatibility:** Portable instructions for using Microsoft Learn MCP-style retrieval; tool names may need mapping in non-MCP runtimes.
> **Trigger:** `microsoft learn, learn mcp, azure docs, dotnet docs, m365 docs, foundry docs, doc freshness`


</details>

## 📦 Domain Skills

<details open>
<summary><h3>M Model Context Protocol</h3></summary>

> Skills for MCP SDKs, protocol behavior, transports, tools, resources, prompts, and client/server correctness.

#### .NET

**`MCP C# SDK 1.4.0`** &nbsp; `mcp-csharp-sdk-140` &nbsp; 👆 Manual &nbsp; P1

Authoritative condensed reference for ModelContextProtocol C#/.NET SDK 1.4.0, including servers, clients, tools,
prompts, resources, transports, sessions, tasks, MRTR, sampling, elicitation, roots, identity, auth, filters,
completions, logging, pagination, HTTP context, McpServer, and McpClient.

<details>
<summary>Capabilities</summary>

- `mcp`
- `dotnet`
- `streamable_http`
- `mrtr`
- `protocol_correctness`

</details>
> **Path:** `skills/packs/mcp-csharp-sdk-1.4.0`
> **License:** `MIT repo wrapper; references summarize public SDK/docs`
> **Compatibility:** Portable Markdown skill. Optional Claude subagent adapter is in adapters/claude/agents/mcp-csharp-sdk-expert.md.
> **Trigger:** `mcp csharp, modelcontextprotocol, mcp server, mcp client, streamable http, mcp tasks, mcp sampling, mcp elicitation, mcp roots`


</details>

<details open>
<summary><h3>S Source Control Platforms</h3></summary>

> Skills for direct forge/repository APIs, pull requests, review workflows, CI runners, releases, and packages.

**`Forgejo Direct API`** &nbsp; `forgejo-direct-api` &nbsp; 👆 Manual &nbsp; P1

Direct Forgejo v15 API reference. Prefer live Swagger and Forgejo-native endpoints over GitHub-shaped assumptions
for repositories, Actions, runners, pull requests, reviews, statuses, releases, packages, webhooks, users, orgs,
and admin work.

<details>
<summary>Capabilities</summary>

- `forgejo_api`
- `actions_runners`
- `pull_requests`
- `releases_packages`
- `swagger_grounding`

</details>
> **Path:** `skills/packs/forgejo-direct-api`
> **License:** `MIT repo wrapper; Forgejo API facts from public Swagger/docs`
> **Compatibility:** Portable Markdown skill with shell helper scripts; requires caller-provided FORGEJO_TOKEN for private probes.
> **Trigger:** `forgejo, forgejo api, forgejo actions, forgejo runners, forgejo pull request, forgejo release, forgejo packages`


**`NuGet Trusted Publishing`** &nbsp; `nuget-trusted-publishing` &nbsp; 👆 Manual &nbsp; P1

Keyless, fully-automated NuGet.org publishing via Trusted Publishing (GitHub Actions OIDC) using the
battle-tested fleet workflow: tag-derived auto-versioning, Must-Publish gate, 3-OS verify, NuGet/login,
auto GitHub release. Kills the wrong "can't publish, API key missing" diagnosis with verified failure-mode
references (policy form traps, index lag, orphaned v-tags, 409s).

<details>
<summary>Capabilities</summary>

- `nuget_publishing`
- `trusted_publishing_oidc`
- `github_actions`
- `release_automation`
- `ci_owned_versioning`

</details>
> **Path:** `skills/packs/nuget-trusted-publishing`
> **License:** `MIT repo wrapper; NuGet.org facts from Microsoft Learn, workflow pattern from the ANcpLua fleet`
> **Compatibility:** Portable Markdown skill; the bundled workflow targets GitHub Actions + nuget.org Trusted Publishing (NuGet/login OIDC).
> **Trigger:** `nuget publish, trusted publishing, nuget api key, dotnet nuget push, nuget-publish.yml, release workflow, authenticate to nuget, NuGet/login, package not on nuget.org, automate nuget release`


</details>

<details open>
<summary><h3>F Frontend UI</h3></summary>

> Skills for UI libraries, component registries, page sections, and frontend integration workflows.

#### React

**`React Bits Pro`** &nbsp; `react-bits-pro` &nbsp; 👆 Manual &nbsp; P1

Install and integrate React Bits Pro premium animated UI components and page blocks into React/Next.js apps using the shadcn registry CLI.

<details>
<summary>Capabilities</summary>

- `react`
- `nextjs`
- `shadcn`
- `animated_ui`
- `landing_blocks`

</details>
> **Path:** `skills/packs/react-bits-pro`
> **License:** `Proprietary upstream component access; this repo stores instructions only`
> **Compatibility:** Portable instructions, but actual component installation requires the user's own React Bits Pro license key and registry access.
> **Trigger:** `react bits, reactbits, animated react components, shadcn registry, premium landing blocks`


</details>

<details open>
<summary><h3>A Architecture Diagramming</h3></summary>

> Skills for generating architecture diagrams, C4 views, and editable diagram artifacts.

**`C4 Diagram`** &nbsp; `c4-diagram` &nbsp; 👆 Manual &nbsp; P1

Generate C4 Container diagrams as editable draw.io XML, with explicit layout, labeled connections,
built-in shapes, and a required legend.

<details>
<summary>Capabilities</summary>

- `c4`
- `architecture_diagrams`
- `drawio`
- `system_design`
- `container_diagrams`

</details>
> **Path:** `skills/packs/c4-diagram`
> **License:** `MIT repo wrapper; no third-party assets included`
> **Compatibility:** Portable Markdown skill that generates editable .drawio XML using built-in diagrams.net shapes.
> **Trigger:** `c4 diagram, container diagram, architecture diagram, system diagram, draw.io, drawio`


</details>

<details open>
<summary><h3>N .NET Platform</h3></summary>

> Skills for .NET target frameworks, SDK/project configuration, source generators, analyzers, and the API/feature constraints those impose.

**`qyl TFM Map`** &nbsp; `qyl-tfm-map` &nbsp; 👆 Manual &nbsp; P1

Know, without being told, which target framework every project in the qyl-workspace compiles for — the
net10.0 baseline (full modern BCL, AOT/trim-aware) versus the small netstandard2.0 Roslyn island (source
generators, analyzers, and the multi-targeted OpenTelemetry libs) — and what each allows or forbids. The
load-bearing nuance it exists to override: on netstandard2.0 modern C# syntax is legal (polyfilled via
ANcpLua.Roslyn.Utilities.Sources) but the net10 runtime BCL is not. Includes the per-project TFM table,
the false-friend projects, the net10-BCL → netstandard2.0 substitution cookbook, and the live analyzer gates.

<details>
<summary>Capabilities</summary>

- `dotnet_tfm`
- `source_generators`
- `roslyn_analyzers`
- `netstandard20_constraints`
- `aot_trim_awareness`

</details>
> **Path:** `skills/packs/qyl-tfm-map`
> **License:** `MIT repo wrapper; project-specific TFM facts read directly from the qyl-workspace csproj files`
> **Compatibility:** Portable Markdown skill. Project-scoped to ~/RiderProjects/qyl-workspace; the map is re-derivable from the csprojs via the command in SKILL.md if the projects change.
> **Trigger:** `target framework, TFM, netstandard2.0, net10, source generator, roslyn analyzer, IsRoslynComponent, multi-target, polyfill, AOT trim, can I use HashCode / System.Text.Json / Span here, qyl workspace`


</details>

<details open>
<summary><h3>A .NET AI & Agent SDKs</h3></summary>

> Skills for .NET AI / agent SDK correctness — Microsoft Agent Framework, Microsoft.Extensions.AI, Foundry — grounded in pinned source over lagging docs.

**`MAF .NET Source-of-Truth`** &nbsp; `maf-dotnet-source-of-truth` &nbsp; 👆 Manual &nbsp; P1

Write Microsoft Agent Framework (.NET) code against the cloned, SHA-pinned source instead of memory or
Microsoft Learn, which lag the source and keep renamed pre-GA signatures alive. Encodes the verified
stale-rename traps (AgentThread→AgentSession, AgentRunResponse→AgentResponse, GetNewThread→CreateSessionAsync,
IChatClient.CompleteAsync→GetResponseAsync), the wrap-in-an-agent-vs-hand-rolled-IChatClient rule, the real
ChatClientAgent/AIAgent signatures, a pre-emit self-check, and the re-grep refresh ritual.

<details>
<summary>Capabilities</summary>

- `microsoft_agent_framework`
- `dotnet_ai_agents`
- `source_of_truth_grounding`
- `api_signature_verification`
- `stale_doc_rename_traps`

</details>
> **Path:** `skills/packs/maf-dotnet-source-of-truth`
> **License:** `MIT repo wrapper; every API fact grep-verified from a local microsoft/agent-framework checkout (>= dotnet-1.10.0)`
> **Compatibility:** Portable Markdown skill. Requires a local clone of microsoft/agent-framework; grep paths assume the dotnet subtree layout (src/, tests/).
> **Trigger:** `microsoft agent framework, Microsoft.Agents.AI, AIAgent, ChatClientAgent, AgentSession, AgentResponse, RunAsync, RunStreamingAsync, IChatClient, AgentThread rename, CompleteAsync gone, MAF dotnet, agent-framework source`


</details>

<details open>
<summary><h3>C CI Automation</h3></summary>

> Skills for CI/CD orchestration — self-hosted runner lifecycle, draining queued runs, VM/engine bring-up and teardown, and scoped cleanup.

**`Self-Hosted CI Orchestration`** &nbsp; `self-hosted-ci-orchestration` &nbsp; 👆 Manual &nbsp; P1

Drive a self-hosted CI runner to a green verdict and back to sleep: wake-safe status, bring the runner
(and its VM/engine) online, drain runs that are queued only because the runner was down, snapshot the
result once (never a live watch), then tear down and reap leaked test containers by label (never a blanket
prune, never named volumes). Encodes the status -> up -> drain -> snapshot -> down+reap loop, the "a stopped
runner is not a blocker" rule, and the two human-gated edges (runner topology / repo visibility; deleting
outside the test-container label).

<details>
<summary>Capabilities</summary>

- `self_hosted_ci`
- `runner_lifecycle`
- `queued_run_draining`
- `scoped_container_reap`
- `teardown_discipline`

</details>
> **Path:** `skills/packs/self-hosted-ci-orchestration`
> **License:** `MIT repo wrapper`
> **Compatibility:** Portable Markdown skill. Assumes a forge with a runner API (e.g. gh) and an idempotent project-local control tool exposing status/up/down/reset/run; machine, VM, and repo specifics live in that tool, not in this skill.
> **Trigger:** `self-hosted runner, runner offline, ci queued not starting, bring the VM up for CI, ci up, ci down, get CI green, self-hosted job not picking up, runner lifecycle, drain queued runs`


</details>

## ⚡ Session Skills

<details open>
<summary><h3>Q Review & Quality</h3></summary>

> On-demand skills for code review, maintainability audits, and implementation-quality judgement.

**`Supercritical Code Quality Review`** &nbsp; `supercritical-code-quality-review` &nbsp; 👆 Manual &nbsp; P1

Maximally strict structural review that hunts complexity-collapse opportunities, oversized files, conditional creep, and unearned abstractions, and defends every finding against refutation before reporting it.

<details>
<summary>Capabilities</summary>

- `code_review`
- `maintainability`
- `abstraction_quality`
- `simplification`
- `adversarial_verification`

</details>
> **Path:** `skills/packs/supercritical-code-quality-review`
> **License:** `MIT (original text in this repo)`
> **Compatibility:** Portable review prompt with an optional Claude nested-agent cascade (adapters/claude/agents/supercritical-review-orchestrator.md). Frontmatter field disable-model-invocation is runtime-specific and safe to ignore when unsupported.
> **Trigger:** `supercritical review, supercritical code quality review, deep maintainability audit, harsh code quality review, thermo-nuclear review`


</details>

<details open>
<summary><h3>P Prompt Engineering</h3></summary>

> On-demand skills for writing, refining, debugging, and evaluating prompts, system prompts, agent instructions, and skill descriptions — including model-specific guidance.

**`Prompt Engineering Expert`** &nbsp; `prompt-engineering-expert` &nbsp; 👆 Manual &nbsp; P1

Diagnose-first help for writing, refining, debugging, and evaluating prompts, system prompts, agent
instructions, CLAUDE.md/AGENTS.md files, and skill trigger descriptions. Leads with locating the failure
case and proposing the smallest change over best-practice checklists, and treats heavy-handed MUSTs as a
code smell to replace with reasoning. Includes model-specific guidance for Claude Fable 5 / Mythos 5:
prune-before-you-add migration, symptom→fix snippets (verbosity, fabricated progress, unrequested actions,
early stopping, context-budget anxiety), scaffolding patterns for long-running agents, effort selection,
and the reasoning-extraction refusal trap.

<details>
<summary>Capabilities</summary>

- `prompt_engineering`
- `system_prompt_design`
- `skill_description_authoring`
- `failure_mode_diagnosis`
- `fable5_migration`

</details>
> **Path:** `skills/packs/prompt-engineering-expert`
> **License:** `MIT (original text in this repo)`
> **Compatibility:** Portable Markdown skill; references are model-agnostic prompt-engineering guidance plus a Claude Fable 5 / Mythos 5 section that maps to Anthropic model behavior.
> **Trigger:** `improve this prompt, write a system prompt, review my instructions, this prompt isn't working, why isn't Claude doing X, the model keeps doing Y, how should I phrase this, agent prompt, skill description, CLAUDE.md, AGENTS.md, few-shot examples, Fable 5, Mythos 5, prompt migration, effort tuning, unexpected refusal`


</details>

---

## Skill Loading Order

Skills are merged in priority order within each scope:

1. **Global Skills** (always loaded first)
2. **Domain Skills** (loaded based on project detection)
3. **Session Skills** (loaded on-demand or by trigger)

Within each scope, lower `priority` numbers load first.

---

## Skill Folder Contract

Each entry points to a folder with a `SKILL.md` file. The portable contract is intentionally small:

- YAML frontmatter with at least `name` and `description`.
- Markdown instructions in the body.
- Optional `references/`, `scripts/`, `assets/`, or runtime adapter files.
- Relative paths in `SKILL.md` are resolved from that skill folder.

Unsupported frontmatter keys should be ignored by runtimes that do not know them.

## Activation Triggers

| Trigger Type | Description |
|--------------|-------------|
| `project_type:*` | Activates for specific project types |
| `file_type:*` | Activates for specific file extensions |
| `error_detected` | Activates when an error/exception occurs |
| `test_run_complete` | Activates after test execution |
| `user_request` | Manual activation only |
| free-form keywords | Runtimes may map natural-language trigger strings to their own routing model |

---

<sub>Generated: 2026-07-07 00:29:25 UTC | Skills: 12 | Categories: 10</sub>
