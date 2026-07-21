# Tasks in 2.0.0-preview.3 — NOT the 1.4.x shape

**The task API left `ModelContextProtocol.Core`.** In `2.0.0-preview.3` it ships as a separate opt-in package, `ModelContextProtocol.Extensions.Tasks` (namespace `ModelContextProtocol.Extensions.Tasks`, TFMs `net10.0;net9.0;net8.0;netstandard2.0`, depends on `ModelContextProtocol` `2.0.0-preview.3`).

Verified against tag `v2.0.0-preview.3` (commit `0d34048`, `src/Directory.Build.props` → `VersionPrefix 2.0.0`) plus the shipped `ModelContextProtocol.Extensions.Tasks.dll`. Nothing here applies to 1.4.x — see `tasks.md` for that.

## Deleted outright

Zero occurrences in **both** `Core` and `Extensions.Tasks` at this tag:

| 1.4.x method | 2.0-preview.3 |
| --- | --- |
| `PollTaskUntilCompleteAsync` | **gone** |
| `GetTaskResultAsync` | **gone** |

Both are folded into `CallToolWithPollingAsync`. Any 1.4.x three-step lifecycle (`CallToolAsTaskAsync` → poll → fetch result) has no 2.0 translation as three calls — it collapses to one.

## Moved out of Core (0 occurrences in Core at this tag)

`IMcpTaskStore`, `InMemoryMcpTaskStore`, `McpTaskStatus`, `ResultOrCreatedTask`, the `tasks/*` request/result types, and `TaskStatusNotificationParams` all now live in `Extensions.Tasks`.

⚠️ **`ResultOrCreatedTask<T>` was not renamed.** The release notes read as though `ResultOrAlternate<T>` replaces it. Source says otherwise: both exist, in different packages and different roles.

- `ResultOrCreatedTask<TResult>` — `Extensions.Tasks/Protocol/`, task-specific, **no** `[Experimental]`
- `ResultOrAlternate<TResult>` — `Core/Protocol/`, new generic handler extension point, `[Experimental(MCPEXP002)]`

## Client surface — all extension methods on `McpClient`

`McpTasksClientExtensions`:

```csharp
ValueTask<ResultOrCreatedTask<CallToolResult>> CallToolAsTaskAsync(
    this McpClient client,
    CallToolRequestParams requestParams,
    CancellationToken cancellationToken = default)

ValueTask<CallToolResult> CallToolWithPollingAsync(
    this McpClient client,
    CallToolRequestParams requestParams,
    int maxConsecutiveStuckPolls = 60,
    CancellationToken cancellationToken = default)

ValueTask<GetTaskResult>    GetTaskAsync(...)     // 2 overloads
ValueTask<UpdateTaskResult> UpdateTaskAsync(...)
ValueTask<CancelTaskResult> CancelTaskAsync(...)  // 2 overloads
```

Three shape changes against 1.4.1:

1. **Arguments are a `CallToolRequestParams`**, not `(toolName, arguments, taskMetadata, …)`. The 1.4.1 named-argument workaround for the `taskMetadata` insertion does not carry over — the parameter list is gone entirely.
2. **`CallToolAsTaskAsync` returns `ValueTask<ResultOrCreatedTask<CallToolResult>>`**, not `ValueTask<McpTask>`. The server may answer immediately *or* create a task; the caller must branch.
3. **`UpdateTaskAsync` is new** (sends input responses back — the MRTR input-required path). `CallToolRawAsync` does not exist at this tag.

### No `IProgress` parameter anywhere

`IProgress`, `ProgressNotificationValue`, and `ProgressToken` have **zero occurrences** in the entire `Extensions.Tasks` package. Progress is no longer a parameter of the task call in any form.

This is the load-bearing consequence for anything that wrapped 1.4.x tasks to bridge progress notifications into telemetry: there is no longer a parameter to hook. On 2.0 that bridge has to come off the client's notification handler, not off the call.

### Protocol gating

`CallToolAsTaskAsync` injects the task capability into `_meta` only when `IsJuly2026OrLaterProtocol(client)`. Against an older-protocol server the call degrades to a plain tool call rather than erroring.

## Server registration

```csharp
// 1.4.x
builder.Services.AddMcpServer(options => options.TaskStore = taskStore);

// 2.0-preview.3 — McpServerOptions.TaskStore is gone
builder.Services.AddMcpServer().WithTasks(taskStore);
```

`WithTasks(this IMcpServerBuilder builder, IMcpTaskStore store)` lives in `McpTasksBuilderExtensions`. Server-side handlers moved to `McpTasksServerExtensions`.

## Diagnostics — the suppression story inverted

**`Extensions.Tasks` contains zero `[Experimental]` attributes.** Task APIs are no longer gated behind `MCPEXP001`. Moving them into a separate opt-in package *replaced* the attribute as the churn signal — you opt in by taking the `PackageReference`, not by suppressing a diagnostic.

Diagnostic IDs at this tag (`src/Common/Experimentals.cs`):

| ID | Constant | Covers | Uses |
| --- | --- | --- | --- |
| `MCPEXP001` | `SpecificationFeature_DiagnosticId` | experimental features in the MCP spec itself | 4 (all in Core) |
| `MCPEXP002` | `Subclassing_DiagnosticId`, `RunSessionHandler_DiagnosticId` | subclassing `McpClient`/`McpServer`; `RunSessionHandler` | 26 |
| `MCPEXP003` | `Apps_DiagnosticId` | MCP Apps extension | 1 |

Consequence: a `NoWarn`/`[Experimental]` propagation carried for `MCPEXP001` on task code becomes dead configuration on 2.0. Delete it rather than porting it.

## Version-drift tripwire

Before answering any task question, check the actual package version.

- `1.4.x` → `tasks.md`. Three-step lifecycle, `IProgress` parameter, `[Experimental(MCPEXP001)]`, `McpServerOptions.TaskStore`.
- `2.0.0-preview.*` → this file. One-call polling, no `IProgress`, no `[Experimental]`, `WithTasks(...)`, separate package.

Confirm the checkout's `src/Directory.Build.props` `VersionPrefix` before grounding any claim in source — a local clone of `modelcontextprotocol/csharp-sdk` typically defaults to `main`.
