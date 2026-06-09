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
| Domain | 3 | 3 |
| Session | 1 | 1 |

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
  - [S Source Control Platforms](#source-control-platforms) (1)
  - [F Frontend UI](#frontend-ui) (1)
    - [React](#react) (1)

- **Session Skills (On-Demand)**
  - [Q Review & Quality](#review--quality) (1)

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

## ⚡ Session Skills

<details open>
<summary><h3>Q Review & Quality</h3></summary>

> On-demand skills for code review, maintainability audits, and implementation-quality judgement.

**`Thermo-Nuclear Code Quality Review`** &nbsp; `thermo-code-quality-review` &nbsp; 👆 Manual &nbsp; P1

Extremely strict maintainability review prompt focused on abstraction quality, giant files, spaghetti-condition growth, and structural simplification opportunities.

<details>
<summary>Capabilities</summary>

- `code_review`
- `maintainability`
- `abstraction_quality`
- `simplification`

</details>
> **Path:** `skills/packs/thermo-nuclear-code-quality-review`
> **License:** `MIT repo wrapper`
> **Compatibility:** Portable review prompt. Frontmatter field disable-model-invocation is runtime-specific and safe to ignore when unsupported.
> **Trigger:** `thermo-nuclear code quality review, thermonuclear review, deep maintainability audit, harsh code quality review`


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

<sub>Generated: 2026-06-09 08:16:25 UTC | Skills: 6 | Categories: 5</sub>
