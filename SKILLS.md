# Skills Registry

> Auto-generated from `skills-registry.yaml` - Do not edit directly

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         SKILLS.md CONTEXT LOADING                           │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────┐   ┌─────────────┐   ┌─────────────┐                       │
│  │   Global    │ → │   Domain    │ → │   Session   │                       │
│  │   Skills    │   │   Skills    │   │   Skills    │                       │
│  └─────────────┘   └─────────────┘   └─────────────┘                       │
│        ↓                 ↓                 ↓                                │
│   [IMMUTABLE]       [PROJECT-SCOPED]   [RUNTIME-LOADED]                    │
│   Core agents       .NET/Web/etc.      Task-specific                       │
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
| Global | 4 | 4 |
| Domain | 5 | 5 |
| Session | 6 | 6 |

---

## Contents

<details open>
<summary>Table of Contents</summary>

- **Global Skills (Always Loaded)**
  - [🔍 Code Analysis](#code-analysis) (2)
  - [⚡ Code Generation](#code-generation) (2)

- **Domain Skills (Project-Scoped)**
  - [🟣 .NET Development](#.net-development) (3)
    - [ASP.NET Core](#asp.net-core) (1)
    - [Entity Framework](#entity-framework) (1)
    - [Blazor](#blazor) (1)
  - [🌐 Web Development](#web-development) (2)
    - [React](#react) (1)
    - [TypeScript](#typescript) (1)

- **Session Skills (On-Demand)**
  - [🐛 Debugging & Diagnostics](#debugging--diagnostics) (2)
  - [✅ Testing & Quality](#testing--quality) (1)
  - [📝 Documentation](#documentation) (1)
  - [🚀 DevOps & CI/CD](#devops--cicd) (2)

</details>

---

## 🌍 Global Skills

<details open>
<summary><h3>🔍 Code Analysis</h3></summary>

> **Analysis skills** examine code structure, patterns, and potential issues
> without making modifications. Read-only inspection capabilities.

**`Static Code Analysis`** &nbsp; `analyze-a1b2c3d4` &nbsp; 🤖 Auto &nbsp; P1

Analyzes code for patterns, anti-patterns, complexity metrics, and potential issues.
Runs automatically when files are opened or modified.

<details>
<summary>Capabilities</summary>

- `complexity_analysis`
- `pattern_detection`
- `dependency_mapping`

</details>
> **Trigger:** `on_file_open`


**`Security Scanner`** &nbsp; `analyze-security01` &nbsp; 🤖 Auto &nbsp; P2

Scans for common security vulnerabilities, secrets in code, and OWASP top 10 issues.

<details>
<summary>Capabilities</summary>

- `vulnerability_scan`
- `secret_detection`
- `dependency_audit`

</details>
> **Trigger:** `on_save`


</details>

<details open>
<summary><h3>⚡ Code Generation</h3></summary>

> **Generation skills** create new code, files, or project structures
> based on templates, patterns, or specifications.

**`Project Scaffolder`** &nbsp; `gen-scaffold01` &nbsp; 👆 Manual &nbsp; P1

Generates project structures, boilerplate code, and configuration files
based on templates and best practices.

<details>
<summary>Capabilities</summary>

- `template_expansion`
- `file_generation`
- `config_creation`

</details>
> **Trigger:** `user_request`


**`Unit Test Generator`** &nbsp; `gen-unittest01` &nbsp; 👆 Manual &nbsp; P2

Generates unit tests for existing code using xUnit, NUnit, or MSTest patterns.

<details>
<summary>Capabilities</summary>

- `test_generation`
- `mock_creation`
- `assertion_patterns`

</details>
> **Trigger:** `user_request`


</details>

## 📦 Domain Skills

<details open>
<summary><h3>🟣 .NET Development</h3></summary>

> **.NET skills** for C#, F#, ASP.NET Core, Entity Framework,
> and the broader .NET ecosystem.

#### ASP.NET Core

**`ASP.NET Core Patterns`** &nbsp; `dotnet-aspnet01` &nbsp; 🤖 Auto &nbsp; P1

Provides ASP.NET Core-specific patterns: controllers, middleware,
dependency injection, and configuration best practices.

<details>
<summary>Capabilities</summary>

- `controller_patterns`
- `middleware_design`
- `di_configuration`

</details>
> **Trigger:** `project_type:aspnet`


#### Entity Framework

**`Entity Framework Core`** &nbsp; `dotnet-efcore01` &nbsp; 🤖 Auto &nbsp; P2

Entity Framework Core patterns: DbContext design, migrations,
query optimization, and relationship mapping.

<details>
<summary>Capabilities</summary>

- `migration_generation`
- `query_optimization`
- `model_configuration`

</details>
> **Trigger:** `project_type:efcore`


#### Blazor

**`Blazor Components`** &nbsp; `dotnet-blazor01` &nbsp; 🤖 Auto &nbsp; P3

Blazor component patterns, state management, and interop capabilities.

<details>
<summary>Capabilities</summary>

- `component_design`
- `state_management`
- `js_interop`

</details>
> **Trigger:** `project_type:blazor`


</details>

<details open>
<summary><h3>🌐 Web Development</h3></summary>

> **Web skills** for frontend frameworks, APIs, and browser technologies.

#### React

**`React Patterns`** &nbsp; `web-react01` &nbsp; 🤖 Auto &nbsp; P1

React 18+ patterns: hooks, server components, suspense, and state management.

<details>
<summary>Capabilities</summary>

- `hook_patterns`
- `component_design`
- `state_patterns`

</details>
> **Trigger:** `project_type:react`


#### TypeScript

**`TypeScript Excellence`** &nbsp; `web-typescript01` &nbsp; 🤖 Auto &nbsp; P2

Advanced TypeScript patterns: generics, utility types, and type-safe APIs.

<details>
<summary>Capabilities</summary>

- `type_inference`
- `generic_patterns`
- `type_guards`

</details>
> **Trigger:** `file_type:*.ts,*.tsx`


</details>

## ⚡ Session Skills

<details open>
<summary><h3>🐛 Debugging & Diagnostics</h3></summary>

> **Debugging skills** activated when errors, exceptions, or unexpected
> behavior is detected. On-demand diagnostic capabilities.

**`Exception Analyzer`** &nbsp; `debug-exception01` &nbsp; 🤖 Auto &nbsp; P1

Analyzes exceptions, stack traces, and error patterns to identify root causes.

<details>
<summary>Capabilities</summary>

- `stack_trace_analysis`
- `error_correlation`
- `fix_suggestions`

</details>
> **Trigger:** `error_detected`


**`Performance Profiler`** &nbsp; `debug-perf01` &nbsp; 👆 Manual &nbsp; P2

Identifies performance bottlenecks, memory leaks, and optimization opportunities.

<details>
<summary>Capabilities</summary>

- `hotspot_detection`
- `memory_analysis`
- `optimization_hints`

</details>
> **Trigger:** `user_request`


</details>

<details open>
<summary><h3>✅ Testing & Quality</h3></summary>

> **Testing skills** for unit tests, integration tests, and quality assurance.

**`Coverage Analyzer`** &nbsp; `test-coverage01` &nbsp; 🤖 Auto &nbsp; P1

Analyzes test coverage and suggests tests for uncovered code paths.

<details>
<summary>Capabilities</summary>

- `coverage_analysis`
- `gap_detection`
- `test_suggestions`

</details>
> **Trigger:** `test_run_complete`


</details>

<details open>
<summary><h3>📝 Documentation</h3></summary>

> **Documentation skills** for generating docs, comments, and explanations.

**`API Documentation`** &nbsp; `doc-api01` &nbsp; 👆 Manual &nbsp; P1

Generates OpenAPI specs, XML docs, and API documentation from code.

<details>
<summary>Capabilities</summary>

- `openapi_generation`
- `xml_docs`
- `markdown_export`

</details>
> **Trigger:** `user_request`


</details>

<details open>
<summary><h3>🚀 DevOps & CI/CD</h3></summary>

> **DevOps skills** for deployment, pipelines, and infrastructure.

**`Docker Configuration`** &nbsp; `ops-docker01` &nbsp; 👆 Manual &nbsp; P1

Generates Dockerfiles, docker-compose configurations, and container best practices.

<details>
<summary>Capabilities</summary>

- `dockerfile_generation`
- `compose_config`
- `optimization_hints`

</details>
> **Trigger:** `user_request`


**`CI/CD Pipeline`** &nbsp; `ops-cicd01` &nbsp; 👆 Manual &nbsp; P2

Generates GitHub Actions, Azure DevOps, or GitLab CI pipeline configurations.

<details>
<summary>Capabilities</summary>

- `github_actions`
- `azure_pipelines`
- `gitlab_ci`

</details>
> **Trigger:** `user_request`


</details>

---

## Skill Loading Order

Skills are merged in priority order within each scope:

1. **Global Skills** (always loaded first)
2. **Domain Skills** (loaded based on project detection)
3. **Session Skills** (loaded on-demand or by trigger)

Within each scope, lower `priority` numbers load first.

---

## Activation Triggers

| Trigger Type | Description |
|--------------|-------------|
| `on_file_open` | Activates when a file is opened |
| `on_save` | Activates when a file is saved |
| `project_type:*` | Activates for specific project types |
| `file_type:*` | Activates for specific file extensions |
| `error_detected` | Activates when an error/exception occurs |
| `test_run_complete` | Activates after test execution |
| `user_request` | Manual activation only |

---

<sub>Generated: 2025-12-08 17:22:39 UTC | Skills: 15 | Categories: 10</sub>
