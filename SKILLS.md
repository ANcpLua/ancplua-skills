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
| Domain | 22 | 22 |
| Session | 11 | 11 |

---

## Contents

<details open>
<summary>Table of Contents</summary>

- **Global Skills (Always Loaded)**
  - [D Documentation Grounding](#documentation-grounding) (2)
    - [Microsoft](#microsoft) (2)

- **Domain Skills (Project-Scoped)**
  - [M Model Context Protocol](#model-context-protocol) (2)
    - [.NET](#.net) (1)
    - [TypeScript](#typescript) (1)
  - [S Source Control Platforms](#source-control-platforms) (3)
  - [F Frontend UI](#frontend-ui) (6)
    - [React](#react) (1)
  - [A Architecture Diagramming](#architecture-diagramming) (1)
  - [N .NET Platform](#.net-platform) (3)
  - [A .NET AI & Agent SDKs](#.net-ai--agent-sdks) (1)
  - [C CI Automation](#ci-automation) (1)
  - [T Testing](#testing) (3)
  - [X ArchCheck Thesis](#archcheck-thesis) (2)

- **Session Skills (On-Demand)**
  - [Q Review & Quality](#review--quality) (5)
  - [P Prompt Engineering](#prompt-engineering) (1)
  - [R Codebase Maturity](#codebase-maturity) (5)

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

**`MCP C# SDK 1.4.1`** &nbsp; `mcp-csharp-sdk-141` &nbsp; 👆 Manual &nbsp; P1

Authoritative condensed reference for ModelContextProtocol C#/.NET SDK 1.4.1, including servers, clients, tools,
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
> **Path:** `skills/packs/mcp-csharp-sdk-1.4.1`
> **License:** `MIT repo wrapper; references summarize public SDK/docs`
> **Compatibility:** Portable Markdown skill. Optional Claude subagent adapter is in adapters/claude/agents/mcp-csharp-sdk-expert.md.
> **Trigger:** `mcp csharp, modelcontextprotocol, mcp server, mcp client, streamable http, mcp tasks, mcp sampling, mcp elicitation, mcp roots`


#### TypeScript

**`MCP TypeScript SDK v2`** &nbsp; `mcp-typescript-sdk-v2` &nbsp; 👆 Manual &nbsp; P1

Authoritative reference for the MCP TypeScript SDK v2 package family (core, server, client, node, express),
as used by qyl.mcp: registerTool/registerResource/registerPrompt with Zod v4, tool-error vs protocol-error
channels, input_required/MRTR with requestState codec, createMcpHandler and serveStdio serving, protocol
eras (legacy 2025 vs modern 2026-07-28), sessions, subscriptions, notifications, and client era negotiation.

<details>
<summary>Capabilities</summary>

- `mcp`
- `typescript`
- `streamable_http`
- `input_required`
- `protocol_eras`
- `protocol_correctness`

</details>
> **Path:** `skills/packs/mcp-typescript-sdk-v2`
> **License:** `MIT repo wrapper; references summarize public SDK/docs`
> **Compatibility:** Portable Markdown skill. Verified against installed @modelcontextprotocol/* 2.0.0 packages and upstream typescript-sdk docs (main @ 3924de9, 2026-08-18).
> **Trigger:** `mcp typescript, modelcontextprotocol server, registerTool, createMcpHandler, serveStdio, ProtocolError, inputRequired, protocol era, server/discover, versionNegotiation, qyl.mcp sdk`


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


**`Extension Store Publishing`** &nbsp; `extension-store-publishing` &nbsp; 👆 Manual &nbsp; P1

Automated browser-extension publishing to all three stores: Edge Add-ons (Partner Center Publish API,
ApiKey), Chrome Web Store (v1.1, OAuth refresh token), Firefox AMO (v5, HS256 JWT). Credential
provisioning per store, upload/poll/publish flows, and verified failure modes (first submission is
manual, secrets shown only once, in-progress/pending-review races, AMO release_notes lang-code object).
Kills the wrong "can't publish, credentials missing" diagnosis.

<details>
<summary>Capabilities</summary>

- `edge_addons_publishing`
- `chrome_web_store_publishing`
- `firefox_amo_publishing`
- `credential_provisioning`
- `extension_release_automation`

</details>
> **Path:** `skills/packs/extension-store-publishing`
> **License:** `Apache-2.0 repo wrapper; store API facts from Microsoft Learn / Google / Mozilla docs, verified end-to-end 2026-07-10`
> **Compatibility:** Portable Markdown skill; reference scripts are dependency-free Node (global fetch). Credentials via env vars only.
> **Trigger:** `extension publish, edge add-ons, chrome web store, firefox add-ons, amo, publish:edge, publish:chrome, publish:firefox, partner center publish api, EDGE_API_KEY, CWS_REFRESH_TOKEN, AMO_JWT_ISSUER, extension submission, store upload`


</details>

<details open>
<summary><h3>F Frontend UI</h3></summary>

> Skills for UI libraries, component registries, page sections, and frontend integration workflows.

**`Emil Design Engineering`** &nbsp; `emil-design-eng` &nbsp; 👆 Manual &nbsp; P2

Emil Kowalski's design-engineering philosophy: UI polish, component design, animation decisions, and the
invisible details that make software feel great.

<details>
<summary>Capabilities</summary>

- `ui_polish`
- `component_design`
- `design_philosophy`

</details>
> **Path:** `skills/packs/emil-design-eng`
> **License:** `MIT — (c) Emil Kowalski, vendored from github.com/emilkowalski/skills (skills.sh)`
> **Compatibility:** Portable Markdown skill.
> **Trigger:** `ui polish, design engineering, interface feel, component design philosophy, invisible details`


**`Animation Vocabulary`** &nbsp; `animation-vocabulary` &nbsp; 👆 Manual &nbsp; P2

Shared vocabulary for describing and choosing web UI motion: easing, springs, durations, and when to use which.

<details>
<summary>Capabilities</summary>

- `animation`
- `motion_design`

</details>
> **Path:** `skills/packs/animation-vocabulary`
> **License:** `MIT — (c) Emil Kowalski, vendored from github.com/emilkowalski/skills (skills.sh)`
> **Compatibility:** Portable Markdown skill.
> **Trigger:** `animation vocabulary, easing, spring animation, duration curves, motion language`


**`Apple Design`** &nbsp; `apple-design` &nbsp; 👆 Manual &nbsp; P2

Apple-inspired interface design principles for building UIs with native-quality feel.

<details>
<summary>Capabilities</summary>

- `apple_hig`
- `ui_design`

</details>
> **Path:** `skills/packs/apple-design`
> **License:** `MIT — (c) Emil Kowalski, vendored from github.com/emilkowalski/skills (skills.sh)`
> **Compatibility:** Portable Markdown skill.
> **Trigger:** `apple design, hig, human interface guidelines, apple-like ui, native feel`


**`Improve Animations`** &nbsp; `improve-animations` &nbsp; 👆 Manual &nbsp; P2

Audit existing UI animations and produce a concrete improvement plan (worksheet-driven).

<details>
<summary>Capabilities</summary>

- `animation_audit`
- `motion_improvement`

</details>
> **Path:** `skills/packs/improve-animations`
> **License:** `MIT — (c) Emil Kowalski, vendored from github.com/emilkowalski/skills (skills.sh)`
> **Compatibility:** Portable Markdown skill with AUDIT.md and PLAN-TEMPLATE.md worksheets.
> **Trigger:** `improve animations, animation audit, fix janky animation, motion review`


**`Review Animations`** &nbsp; `review-animations` &nbsp; 👆 Manual &nbsp; P2

Review UI animations against a written motion-quality standard.

<details>
<summary>Capabilities</summary>

- `animation_review`
- `motion_standards`

</details>
> **Path:** `skills/packs/review-animations`
> **License:** `MIT — (c) Emil Kowalski, vendored from github.com/emilkowalski/skills (skills.sh)`
> **Compatibility:** Portable Markdown skill with STANDARDS.md reference.
> **Trigger:** `review animations, animation standards, motion quality check`


#### React

**`React Bits Pro`** &nbsp; `react-bits-pro` &nbsp; 👆 Manual &nbsp; P1

Install and integrate React Bits Pro premium animated UI components, page-section blocks, and
landing-page templates into React/Next.js apps via the shadcn registry CLI with license-key
authentication. Covers 101 components, 238 blocks across 21 categories, and 11 templates.

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
> **Trigger:** `react bits, reactbits, @reactbits-starter, @reactbits-pro, animated react components, shadcn registry, premium landing blocks, page sections, landing page template`


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


**`SLNX for Rider`** &nbsp; `slnx-rider` &nbsp; 👆 Manual &nbsp; P1

Organize a .slnx solution file and make Rider index everything in it: creating, cleaning up, reorganizing, or
migrating .slnx/.sln files; MSBuild config files (Directory.Build.props, Directory.Packages.props, global.json,
nuget.config, .editorconfig) or docs missing from the solution tree; and validating a .slnx against Slnx.xsd.

<details>
<summary>Capabilities</summary>

- `slnx`
- `solution_organization`
- `rider_indexing`
- `xsd_validation`

</details>
> **Path:** `skills/packs/slnx-rider`
> **License:** `MIT; bundled Slnx.xsd under MIT (assets/Slnx.xsd.LICENSE)`
> **Compatibility:** Portable Markdown skill with the Slnx.xsd schema in assets/ and an XSD-gap reference.
> **Trigger:** `slnx, sln migration, solution file cleanup, rider not indexing, Directory.Build.props not showing, solution items, Slnx.xsd`


**`Fallout Build`** &nbsp; `fallout-build` &nbsp; 👆 Manual &nbsp; P1

Write, change, review, or run Fallout (NUKE) builds: exemplar-first layout, exact pins for SDK, packages, tools,
images and actions, target chains with .Produces/Assert/ReportSummary, generated GitHub workflows, and a
two-run reproducibility proof. Includes running ArchCheck's Containers/Tool/Analyze/Spans targets.

<details>
<summary>Capabilities</summary>

- `fallout_build`
- `exact_pinning`
- `workflow_generation`
- `archcheck_targets`

</details>
> **Path:** `skills/packs/fallout-build`
> **License:** `MIT (original text in this repo)`
> **Compatibility:** Portable Markdown skill with references; exemplar paths are relative to a local examplefalloutbuilds checkout (<examples>).
> **Trigger:** `fallout build, nuke build, Build.cs, _build.csproj, build.sh, pin build tools, GitHubActions workflow generation, add fallout target, run archcheck build`


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

<details open>
<summary><h3>T Testing</h3></summary>

> Skills for writing, reviewing, and proving tests — test frameworks and red-on-old/green-on-new proofs of dependency behaviour changes.

**`Prove Fix Across Versions`** &nbsp; `prove-fix-across-versions` &nbsp; 👆 Manual &nbsp; P1

Prove each behaviour change between two versions of a dependency with a test that is red on OLD and green on NEW.
For "fixed in X" / "changed in X" claims, re-verifying version claims in docs or changelogs, confirming an upstream
fix, and diagnosing a bug before reporting it upstream. Plain version bumps with no behavioural claim are out of scope.

<details>
<summary>Capabilities</summary>

- `version_claim_proof`
- `red_green_tests`
- `changelog_verification`
- `upstream_diagnosis`

</details>
> **Path:** `skills/packs/prove-fix-across-versions`
> **License:** `MIT (original text in this repo)`
> **Compatibility:** Portable Markdown skill with a .NET reference and graded evals (evals/ fixtures and scaffold scripts).
> **Trigger:** `fixed in, changed in, version bump claim, verify changelog claim, upstream fix, red on old green on new, re-verify version claims, report upstream bug`


**`TUnit Extensions`** &nbsp; `tunit-extensions` &nbsp; 👆 Manual &nbsp; P1

Write, review, troubleshoot, or migrate tests using TUnit, TUnit.Assertions, or TUnit.Mocks: ordinary tests and
assertions, data sources and matrices, fixture lifecycles, custom assertions, executors, async isolation, and
TUnit/Microsoft.Testing.Platform runner problems.

<details>
<summary>Capabilities</summary>

- `tunit`
- `assertions`
- `data_sources`
- `fixture_lifecycle`
- `mtp_runner`

</details>
> **Path:** `skills/packs/tunit-extensions`
> **License:** `Derivative of the official TUnit skill v1.68.4 (MIT); attribution in UPSTREAM-NOTICE.md`
> **Compatibility:** Portable Markdown skill with task-specific references and evals (evals/evals.json, trigger-queries.json).
> **Trigger:** `tunit, TUnit.Assertions, TUnit.Mocks, data source, matrix tests, fixture lifecycle, custom assertion, test executor, async isolation, mtp runner`


**`MSTest Extensions`** &nbsp; `mstest-extensions` &nbsp; 👆 Manual &nbsp; P1

Write, review, troubleshoot, or migrate MSTest tests on Microsoft.Testing.Platform: data-driven cases, fixture
lifecycle and TestContext, cooperative timeouts, parallel isolation, Assert.Throws and Assert.That extensions,
custom test attributes, and MTP discovery, filters, exit codes, and extensions. The MSTest counterpart of tunit-extensions.

<details>
<summary>Capabilities</summary>

- `mstest`
- `data_driven_tests`
- `fixture_lifecycle`
- `mtp_runner`
- `custom_assertions`

</details>
> **Path:** `skills/packs/mstest-extensions`
> **License:** `MIT (original text in this repo; summarizes Microsoft Learn MSTest docs with links)`
> **Compatibility:** Portable Markdown skill with task-specific references; written against MSTest 4.4 and Microsoft.Testing.Platform 2.4, with version notes for earlier releases.
> **Trigger:** `mstest, MSTest.Sdk, DataRow, DynamicData, TestDataRow, CombinatorialData, TestContext, ClassInitialize, Assert.ThrowsExactly, Assert.That, mtp runner, --filter`


</details>

<details open>
<summary><h3>X ArchCheck Thesis</h3></summary>

> Project skills for the ArchCheck thesis workspace — the twbook LaTeX document and ArchCheck rule evaluation. Project paths are relative to the thesis workspace.

**`twbook (ArchCheck Thesis)`** &nbsp; `archcheck-twbook` &nbsp; 👆 Manual &nbsp; P1

Edit the thesis workspace's twbook LaTeX class, document content, bibliography, and PDF layout: template
configuration, bibliography handling, compilation, and PDF verification.

<details>
<summary>Capabilities</summary>

- `latex_class`
- `bibliography`
- `pdf_verification`

</details>
> **Path:** `skills/packs/twbook`
> **License:** `MIT (original text in this repo)`
> **Compatibility:** Project skill for the ArchCheck thesis workspace; project paths are relative to the thesis repository root.
> **Trigger:** `twbook, thesis latex class, bibliography, citation problem, pdf layout, document compilation`


**`ArchCheck Evaluation`** &nbsp; `archcheck-evaluation` &nbsp; 👆 Manual &nbsp; P1

Develop ArchCheck's static or runtime rules, analyze repository or trace evidence, and evaluate findings and
coverage: SR1-SR6, RT1-RT3, inference, SARIF interpretation, and empirical result claims.

<details>
<summary>Capabilities</summary>

- `static_rules`
- `runtime_rules`
- `sarif`
- `precision_recall`

</details>
> **Path:** `skills/packs/archcheck-evaluation`
> **License:** `MIT (original text in this repo)`
> **Compatibility:** Project skill for ArchCheck; project paths are relative to the ArchCheck/ directory. Build targets: fallout-build references/archcheck.md.
> **Trigger:** `archcheck rules, SR1-SR6, RT1-RT3, ownership inference, sarif, finding aggregation, precision recall, empirical claims`


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


**`Tech Debt Accretion Audit`** &nbsp; `tech-debt` &nbsp; 👆 Manual &nbsp; P1

Evidence-grounded technical-debt audit hunting accretion — code that was added (shimmed, wrapped,
re-validated, try/catch-padded) when it should have been deleted — plus .NET NativeAOT, trimming,
and source-generator hazards. Every finding is path:line + snippet + the deletion that removes it;
a required "looks bad but is fine" section protects intentional boundaries. Priority = (Impact + Risk) x (6 - Effort).

<details>
<summary>Capabilities</summary>

- `accretion_hunting`
- `deletion_first`
- `nativeaot_trimming`
- `source_generators`
- `evidence_gate`

</details>
> **Path:** `skills/packs/tech-debt`
> **License:** `MIT`
> **Compatibility:** Portable Markdown skill. Eight Claude agent adapters in adapters/claude/agents/debt-*.md run it as a pipeline: router, three read-only hunters (accretion, lifecycle, aot), contracts brake, arbiter, and two writers (deleter, boundary-fix) with a net-negative line-delta gate.
> **Trigger:** `tech debt, technical debt audit, what should we refactor, code health, refactoring priorities, maintenance backlog, accretion audit`


**`Derot Dependency Verification`** &nbsp; `derot-deps` &nbsp; 👆 Manual &nbsp; P1

Audit dependency choices and migration claims against manifests, the resolved dependency graph,
exact shipped package source, upstream releases, and official vendor documentation. Never asserts
containment, replacement, or succession from memory; package naming similarity is not evidence;
unverified claims are marked as such with the missing evidence named.

<details>
<summary>Capabilities</summary>

- `dependency_graph`
- `package_source_verification`
- `migration_claims`
- `evidence_gate`

</details>
> **Path:** `skills/packs/derot`
> **License:** `MIT`
> **Compatibility:** Portable Markdown skill with one reference (dependency-verification.md). Evidence-first and proposal-only: flags dependency changes, never applies them during an audit.
> **Trigger:** `why do we have this dependency, redundant package, transitive dependency, meta package, superseded package, dependency migration, derot`


**`Improve`** &nbsp; `improve-handoff` &nbsp; 👆 Manual &nbsp; P1

Survey a codebase as a senior advisor and produce prioritized, self-contained handoff plans for other agents to execute. Strictly read-only on source: writes only under plans/, never edits code. Fable 5 advisor with Opus 5 workers, matching the standing multi-agent-teams model policy.

<details>
<summary>Capabilities</summary>

- `codebase_audit`
- `prioritization`
- `handoff_planning`
- `product_direction`
- `plan_execution_review`

</details>
> **Path:** `skills/packs/improve`
> **License:** `MIT — (c) shadcn, vendored from github.com/shadcn/improve; Fable 5 adaptation by Alex`
> **Compatibility:** Portable Markdown skill plus three references (audit-playbook, plan-template, closing-the-loop). The execute variant needs a host that can spawn subagents in an isolated git worktree; planning works without one.
> **Trigger:** `improve, audit this codebase, find improvement opportunities, what should I work on next, roadmap, tech debt audit, handoff plan, write a plan for another agent, /improve, execute plan, reconcile plans`


**`Grounding Audit`** &nbsp; `grounding-audit` &nbsp; 👆 Manual &nbsp; P1

Sweep a repository for poisoned grounding: claims ABOUT the code (doc comments, examples, README API sketches, prose test assertions, CHANGELOG current-state claims) that the code never satisfied or has drifted from. Verify each claim against actual behavior, classify true/lie/stale/unverifiable, trace the poisoning chain, fix with code-wins-unless-intent rules, and restructure (golden prose test, structured API, invariant output) so the lie cannot recur.

<details>
<summary>Capabilities</summary>

- `claim_verification`
- `doc_truth_audit`
- `prose_to_structure_refactor`
- `poisoning_chain_tracing`

</details>
> **Path:** `skills/packs/grounding-audit`
> **License:** `MIT (original text in this repo)`
> **Compatibility:** Portable Markdown skill; needs only repo read access plus the ability to build/run for output-claim verification.
> **Trigger:** `grounding audit, doku lügt, docs lie, poisoned grounding, doc example wrong, stale docs, verify claims against code, prose assertion, bauchgefühl code smell, docs don't match code, /grounding-audit`


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

<details open>
<summary><h3>R Codebase Maturity</h3></summary>

> On-demand, evidence-first maintenance routines — mutation testing, emitter corpora, performance-claim gates, autonomous maintenance runs, and agent-log scans.

**`Agent Log Scan`** &nbsp; `agent-log-scan` &nbsp; 👆 Manual &nbsp; P1

Scan Claude Code agent transcripts (session-history JSONL) for antipatterns — retry loops, permission thrash,
API dead-ends, usage-limit interruptions — and turn them into config and routine changes that raise autonomy.

<details>
<summary>Capabilities</summary>

- `transcript_analysis`
- `antipattern_detection`
- `permission_tuning`

</details>
> **Path:** `skills/packs/agent-log-scan`
> **License:** `MIT (from ANcpLua/maturity-skills)`
> **Compatibility:** Portable Markdown skill with Python helper scripts; Codex UI metadata in agents/openai.yaml.
> **Trigger:** `scan agent logs, analyze session history, why do my agents keep failing, retry loops, permission thrash, usage-limit interruptions, cut permission prompts`


**`Emitter Corpus`** &nbsp; `emitter-corpus` &nbsp; 👆 Manual &nbsp; P1

Validate a parser or importer against a corpus of files as real upstream producers actually write them, and land
that corpus as permanent CI fixtures.

<details>
<summary>Capabilities</summary>

- `corpus_validation`
- `interop_fixtures`
- `format_compatibility`

</details>
> **Path:** `skills/packs/emitter-corpus`
> **License:** `MIT (from ANcpLua/maturity-skills)`
> **Compatibility:** Portable Markdown skill; Codex UI metadata in agents/openai.yaml.
> **Trigger:** `does it work with X's files, format compatibility testing, interop validation, parser corpus, regression corpus, interop fixtures`


**`Maintenance Run`** &nbsp; `maintenance-run` &nbsp; 👆 Manual &nbsp; P1

Orchestrate a full autonomous maintenance run on a repo: parallel finders, root-cause dedupe, adversarial
verification, a fixer fleet with disjoint ownership, single-writer integration, and a hard termination rule.

<details>
<summary>Capabilities</summary>

- `maintenance_orchestration`
- `finding_dedupe`
- `adversarial_verification`
- `termination_rule`

</details>
> **Path:** `skills/packs/maintenance-run`
> **License:** `MIT (from ANcpLua/maturity-skills)`
> **Compatibility:** Portable Markdown skill with a Python findings helper; Codex UI metadata in agents/openai.yaml.
> **Trigger:** `autonomous maintenance run, repo health pass, find and fix everything, scheduled repo maintenance, multi-agent bug hunt, when should the loop stop`


**`Mutation Tester`** &nbsp; `mutation-tester` &nbsp; 👆 Manual &nbsp; P1

Run mutation testing and turn surviving mutants into targeted tests, or keep a recorded mutation-score baseline as
a regression gate that proves repeated maintenance runs did not weaken the suite.

<details>
<summary>Capabilities</summary>

- `mutation_testing`
- `surviving_mutants`
- `score_baseline`

</details>
> **Path:** `skills/packs/mutation-tester`
> **License:** `MIT (from ANcpLua/maturity-skills)`
> **Compatibility:** Portable Markdown skill; Codex UI metadata in agents/openai.yaml.
> **Trigger:** `mutation testing, mutation score, stryker, how good are my tests really, test-suite strength, test gaps beyond coverage`


**`Perf Gate`** &nbsp; `perf-gate` &nbsp; 👆 Manual &nbsp; P1

Measure a project's own performance claims (README, docs) against reality and attribute regressions to code.

<details>
<summary>Capabilities</summary>

- `perf_claim_verification`
- `benchmarking`
- `regression_attribution`

</details>
> **Path:** `skills/packs/perf-gate`
> **License:** `MIT (from ANcpLua/maturity-skills)`
> **Compatibility:** Portable Markdown skill; Codex UI metadata in agents/openai.yaml.
> **Trigger:** `verify performance claim, benchmark a tool, does it really handle X MB, streaming claim, O(n) claim, perf baseline`


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

<sub>Generated: 2026-09-30 04:22:46 UTC | Skills: 35 | Categories: 13</sub>
