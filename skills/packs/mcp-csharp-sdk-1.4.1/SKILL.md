---
name: mcp-csharp-sdk-1.4.1
description: Authoritative reference for the Model Context Protocol C#/.NET SDK 1.4.1. Use for MCP servers, clients, tools, prompts, resources, transports, sessions, tasks, sampling, elicitation, roots, identity, auth, filters, completions, logging, pagination, HTTP context, McpServer, McpClient, and ModelContextProtocol.* APIs. Always load the relevant reference file before answering.
---

# MCP C# SDK 1.4.1 — Expert Reference

This skill is the authoritative reference for the MCP C# SDK at v1.4.1. It mirrors the conceptual documentation at https://csharp.sdk.modelcontextprotocol.io/concepts/index.html, distilled to load-bearing API surfaces, code patterns, and sharp edges.

**Always consult the right reference file before answering** — pre-1.4.x patterns (e.g. the old positional `CallToolAsTaskAsync(toolName, args, progress, ct)` signature — the method exists but `taskMetadata` is now the 3rd parameter, the older `WithSubscribeToResourcesHandler` shape, lifecycle changes in `IMcpTaskStore`) are not canonical. Neither are post-1.4.x main-branch features (MRTR, `DRAFT-2026-v1`, `[McpHeader]`, MCP Apps) — main is the 2.0.0-preview line; see `references/mrtr.md`.

## What changed in 1.4.1 (vs 1.4.0)

Exactly one code change (verified: `diff` of the two release trees touches only `src/ModelContextProtocol.Core/Server/StreamableHttpServerTransport.cs`, `Directory.Build.props`, and `PACKAGE.md`):

- **SSE memory-leak fix** (PR #1628): `StreamableHttpServerTransport` now disposes its `SseEventWriter` (and thus releases the SSE response-stream reference) in a `finally` block as soon as the GET request ends, instead of holding it until the session is disposed via explicit DELETE or idle timeout. Long-lived SSE clients that disconnect without DELETE no longer pin the Kestrel connection and its memory-pool buffers (~20 MiB/session). `SendMessageAsync` now null-checks the writer (messages still go to the resumability event store when configured, so `Last-Event-ID` replay is unaffected).

No API surface changed. Everything else in this pack applies to 1.4.0 and 1.4.1 equally.

## Provenance — how this pack was verified (and a trap to avoid)

Claims here were grep-verified against the **actual release tree**: `github.com/modelcontextprotocol/csharp-sdk` commit `2b7fd35` = tag `v1.4.1` on branch `release/1.x` (`src/Directory.Build.props` → `VersionPrefix 1.4.1`), cross-checked against string contents of the shipped `ModelContextProtocol.Core.dll` (`InformationalVersion 1.4.1+2b7fd35...`). `git log v1.4.0..v1.4.1` contains only the #1628 backport plus release prep. A full clone lives at `~/RiderProjects/qyl-references/csharp-sdk` for future verification — but note its default checkout is `main` (= 2.0.0-preview); always `git switch --detach v1.4.1` (or diff against the tag) before grounding 1.4.x claims.

⚠️ **Trap:** a source checkout resolved from nupkg commit metadata can silently contain the wrong tree (observed 2026-07-16: an opensrc cache directory named by the 1.4.x release SHA actually held main-branch 2.0.0-preview source). Before grounding any claim in a checkout, confirm its `src/Directory.Build.props` `VersionPrefix` matches the package version. An earlier revision of this pack documented main-only MRTR APIs as 1.4.0 surface because of exactly this failure.

## How to use this skill

When a request touches an MCP concept, read the matching reference file from `references/` first. Each file is condensed (50-150 lines) — read fully, then answer. Cross-cutting decisions (session mode, transport choice, identity flow) appear in multiple files; the routing table below tells you which is authoritative for each topic.

## Routing table — read the indicated reference first

| User asks about | Read |
| --- | --- |
| Installation, NuGet picks, first server, first client | `references/getting-started.md` |
| Capability negotiation, what client/server supports | `references/capabilities.md` |
| stdio, Streamable HTTP, legacy SSE, session resumption, host validation | `references/transports.md` |
| Ping / connection health | `references/ping.md` |
| Progress notifications, `IProgress<>`, progressToken | `references/progress.md` |
| Cancellation, `notifications/cancelled`, `tasks/cancel` | `references/cancellation.md` |
| Long-running operations, `IMcpTaskStore`, `InMemoryMcpTaskStore`, `ToolTaskSupport`, fault tolerance | `references/tasks.md` |
| MRTR / `DRAFT-2026-v1` / `InputRequiredException` (**not shipped in 1.4.x** — read before denying or affirming) | `references/mrtr.md` |
| Sampling (server→client LLM calls) | `references/sampling.md` |
| Roots (client filesystem URIs) | `references/roots.md` |
| Elicitation, Form vs URL mode, `UrlElicitationRequiredException` | `references/elicitation.md` |
| Tools — definition, content blocks, errors, list changes | `references/tools.md` |
| Resources — direct, template, subscriptions | `references/resources.md` |
| Prompts — `ChatMessage`, `PromptMessage`, rich content | `references/prompts.md` |
| Completions — `[AllowedValues]`, `WithCompleteHandler` | `references/completions.md` |
| Logging — server→client log notifications, level mapping | `references/logging.md` |
| Pagination, cursors, manual page-by-page | `references/pagination.md` |
| Stateless vs stateful, sessions, `Mcp-Session-Id`, DI scope, backpressure | `references/stateless.md` |
| `IHttpContextAccessor`, headers / query / route values | `references/httpcontext.md` |
| Filters — message filters, request filters, common patterns | `references/filters.md` |
| Identity, `ClaimsPrincipal` injection, `[Authorize]`, `AddAuthorizationFilters`, stdio identity | `references/identity.md` |

## Top-level decision tree

### Picking a transport

```
Local single-process integration (IDE, CLI tool) → stdio
Remote / multi-user, no GET-channel features needed → Streamable HTTP, Stateless = true
Remote with sampling / elicitation / roots / resource subscriptions → Streamable HTTP, Stateless = false
Legacy clients only speak SSE → Stateful + EnableLegacySse = true (transitional)
```

### Picking a session mode (Streamable HTTP)

| Question | Stateful (`false`) | Stateless (`true`) |
| --- | --- | --- |
| Server needs legacy direct sampling / elicitation / roots / unsolicited notifications? | ✓ | ✗ |
| Resource subscriptions needed? | ✓ | ✗ |
| Per-client isolation required? | ✓ | ✗ |
| Multi-replica deployment without sticky sessions? | ✗ | ✓ |
| Serverless / Lambda / Functions? | ✗ | ✓ |
| Local dev where editor "reset" = new session? | ✓ | ✗ |

**Always set explicitly.** The current SDK default (`false`) is expected to change. Setting it explicitly insulates you from that.

### Defining a primitive — pick the entry point

| Primitive | Default mechanism | Factory |
| --- | --- | --- |
| Tool | `[McpServerToolType]` + `[McpServerTool]` | `McpServerTool.Create(delegate / MethodInfo / AIFunction, options)` |
| Prompt | `[McpServerPromptType]` + `[McpServerPrompt]` | `McpServerPrompt.Create(...)` |
| Resource | `[McpServerResourceType]` + `[McpServerResource]` | `McpServerResource.Create(...)` |

Attribute-based for static catalogues. Factory-based for runtime-built dynamic catalogues. Register via `WithTools<T>()` / `WithPrompts<T>()` / `WithResources<T>()` — or `WithToolsFromAssembly()` etc. for assembly-wide auto-discovery.

### Auto-injected parameters (all primitives)

These types in a method signature are resolved by the SDK and **excluded from the JSON schema**:

- `McpServer` — current server instance (from DI)
- `IProgress<ProgressNotificationValue>` — bridges to `notifications/progress`
- `ClaimsPrincipal` / `ClaimsPrincipal?` — current user (HTTP middleware or stdio filter)
- `RequestContext<TParams>` — full request envelope
- `CancellationToken` — linked to request / session lifecycle
- Any DI-registered service

## Cross-cutting patterns

### Capability checking is mandatory before optional features

```csharp
// Client checks server
if (client.ServerCapabilities?.Resources is { Subscribe: true })
    await client.SubscribeToResourceAsync(uri);

// Server checks client (in a tool, etc.)
if (server.ClientCapabilities?.Sampling is null)
    throw new McpException("Client does not support sampling");
```

Calling a feature on a peer that didn't advertise it → `InvalidOperationException`. Always check.

### Error model — tool errors vs protocol errors

| Throw | Result |
| --- | --- |
| `McpProtocolException(msg, McpErrorCode.X)` | JSON-RPC error response (e.g. `-32602 InvalidParams`) |
| `OperationCanceledException` | Re-thrown as cancellation |
| `McpException(msg)` | `CallToolResult { IsError = true, Content = [TextContentBlock { Text = msg }] }` |
| Any other `Exception` | `CallToolResult { IsError = true, Content = [TextContentBlock { Text = "An error occurred invoking 'X'." }] }` — message redacted |

**The redaction matters.** If you want the LLM to see useful failure text, throw `McpException(msg)` or wrap in a request filter that returns a structured `IsError` result with detail.

### What stateless mode breaks

The full list is in `references/stateless.md`. Quick summary of what *only works in stateful or stdio*:

- Legacy server-to-client requests: `SampleAsync`, `ElicitAsync` (Form mode), `RequestRootsAsync`, server-side ping
- Unsolicited notifications: `notifications/resources/updated`, `notifications/tools/list_changed`, `notifications/prompts/list_changed`, `notifications/resources/list_changed`, `notifications/message` (server log emit)
- Resource subscriptions
- `notifications/cancelled` (cancellation propagation across the JSON-RPC layer)
- `notifications/elicitation/complete`

What **does still work in stateless**:
- `notifications/progress` — written into the open POST response stream during a handler, not via GET channel
- Tasks (full lifecycle) — store is shared across ephemeral server instances
- `ClaimsPrincipal` injection, `[Authorize]`, `AddAuthorizationFilters()`
- `IHttpContextAccessor`
- `UrlElicitationRequiredException` (stateless escape hatch for OAuth-style flows)

### Identity flow — one path, multiple expressions

```
HTTP request with auth token
  → ASP.NET Core auth middleware (HttpContext.User)
  → MCP transport copies User into JsonRpcMessage.Context.User
  → ClaimsPrincipal parameter, context.User in filters, [Authorize] attributes
```

Stdio servers can populate `context.User` from a message filter (env-var based identity).

The canonical authorisation chain:

```csharp
services.AddMcpServer()
    .WithHttpTransport(o => o.Stateless = true)
    .AddAuthorizationFilters()              // enables [Authorize] on tool methods
    .WithTools<MyTools>();
```

```csharp
[McpServerTool, Authorize(Roles = "Admin")]
public string AdminOp(string action) => ...;
```

List ops auto-filter unauthorised items. Individual ops return JSON-RPC error.

### Notification methods — always use `NotificationMethods.X` constants

Don't hand-type method strings. Use the constants:
- `NotificationMethods.ProgressNotification`
- `NotificationMethods.CancelledNotification`
- `NotificationMethods.ToolListChangedNotification`
- `NotificationMethods.PromptListChangedNotification`
- `NotificationMethods.ResourceListChangedNotification`
- `NotificationMethods.ResourceUpdatedNotification`
- `NotificationMethods.RootsListChangedNotification`
- `NotificationMethods.LoggingMessageNotification`
- `NotificationMethods.ElicitationCompleteNotification`

## Sharp edges / common mistakes

### `Trace` log level is dropped

`ILogger.LogTrace(...)` → silently dropped when forwarding to MCP client. MCP has no equivalent below `Debug`. Use `LogDebug` if you want it across the wire.

### Stdio stdout discipline

Any byte to `stdout` outside JSON-RPC framing corrupts the protocol stream. Always:

```csharp
builder.Logging.AddConsole(o => o.LogToStandardErrorThreshold = LogLevel.Trace);
```

### Pagination cursor — empty string is *not* a terminator

Spec-mandated: any non-null cursor (including `""`) means more pages. Never emit empty string on the final page. Clients can defensively treat empty string as `null`.

### `notifications/cancelled` vs `tasks/cancel`

For regular requests → `notifications/cancelled` (fire-and-forget). For task-augmented requests → spec **requires** `tasks/cancel` (request/response). The SDK uses separate cancellation tokens per task, so `tasks/cancel` works even after the originating HTTP request has completed.

### `PerSessionExecutionContext = true` breaks `IHttpContextAccessor`

The two options are incompatible — execution context is captured at session creation, not per request. If you need session-scoped `AsyncLocal<T>`, you give up per-request `HttpContext` access in handlers.

### `EnableLegacySse = true` + `Stateless = true` → startup exception

SSE requires shared in-memory state between GET and POST endpoints. Mutually exclusive with stateless.

### `Mcp-Session-Id` vs `mcp.session.id` activity tag

Same name, different things:
- `Mcp-Session-Id` HTTP header = transport session ID (server-assigned during init)
- `mcp.session.id` activity tag = per-`McpServer`-instance GUID (different from the header)

In stateful mode, the activity tag is stable across a session. In stateless, each request gets a new `McpServer` instance with a new tag. To correlate, add an endpoint filter that copies the HTTP header into the request activity tag — see `references/stateless.md` for the snippet.

### `[Authorize]` only fires if `AddAuthorizationFilters()` is called

The attributes don't auto-wire. Explicit chain step needed during builder setup.

### `McpClientOptions.InitializeMeta` was removed in 1.4.0

Do not recommend it for initialization metadata. If a user needs metadata, verify the 1.4.0 source/docs for the specific supported path instead of carrying over older samples.

### `WithToolsFromAssembly()` finds **all** `[McpServerToolType]` classes

Including those you may have forgotten to delete. Prefer explicit `WithTools<T>()` when you want surgical control over what's registered (e.g. feature-flagged tool sets).

## References to the spec and samples

- Conceptual docs index: https://csharp.sdk.modelcontextprotocol.io/concepts/index.html
- API reference: https://csharp.sdk.modelcontextprotocol.io/api/
- Samples directory: https://github.com/modelcontextprotocol/csharp-sdk/tree/main/samples
  - `ProtectedMcpServer` — JWT + protected-resource metadata
  - `LongRunningTasks` — File-based `IMcpTaskStore` + `McpTask` returning tools
  - `AspNetCoreMcpPerSessionTools` — Per-session tool filtering via `ConfigureSessionOptions`
  - `InMemoryTransport` — Custom transport setup with `McpServer.Create`
- MRTR: `references/mrtr.md` — a correction note; MRTR is NOT in 1.4.x (the upstream `docs/concepts/mrtr/` docs describe main-branch 2.0.0-preview surface)
- Protocol spec: https://modelcontextprotocol.io/specification/2025-11-25
