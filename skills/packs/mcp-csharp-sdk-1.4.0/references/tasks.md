# Tasks — long-running operation pattern

**Status:** Experimental in spec (`2025-11-25` draft). API may change.

## What it is

A "call-now, fetch-later" pattern. Client initiates a tool call with a `Task` augmentation, server creates a task record and returns `taskId` immediately, client polls / receives notifications, then fetches the result. Lets clients disconnect/reconnect across long operations.

## Lifecycle

```
working → completed | failed | cancelled
        \→ input_required → working (resumes after elicitation)
```

Terminal states are final.

## Server: enabling tasks

```csharp
var taskStore = new InMemoryMcpTaskStore();

builder.Services.AddMcpServer(options =>
{
    options.TaskStore = taskStore;
    options.SendTaskStatusNotifications = true;  // optional
})
.WithHttpTransport(o => o.Stateless = true)
.WithTools<MyTools>();
```

The `AddMcpServer(Action<McpServerOptions>)` overload takes options inline. Wiring `TaskStore` via `IOptions.Configure<>` works but is indirect — prefer the direct form.

## InMemoryMcpTaskStore constructor

```csharp
new InMemoryMcpTaskStore(
    defaultTtl: TimeSpan.FromHours(1),       // default retention
    maxTtl: TimeSpan.FromHours(24),          // client-requested TTL ceiling
    pollInterval: TimeSpan.FromSeconds(1),   // client poll hint
    cleanupInterval: TimeSpan.FromMinutes(5),// expired-task sweep
    pageSize: 100,                           // ListTasks page size
    maxTasks: 1000,                          // global cap
    maxTasksPerSession: 100                  // per-session cap
);
```

Reference implementation — single-server, no durability. For multi-replica / restart-survivable: implement `IMcpTaskStore` against persistent backing (DB / Redis / file).

## Tool task support levels

`ToolExecution.TaskSupport`:

| Value | Default for | Meaning |
| --- | --- | --- |
| `Forbidden` | sync methods | Cannot be called with task augmentation |
| `Optional` | async methods | Caller chooses sync vs task path |
| `Required` | — | Must use task augmentation |

Async-returning tools (`Task<T>` / `ValueTask<T>`) auto-advertise `Optional`. Set explicitly via `McpServerTool.Create(..., new McpServerToolCreateOptions { Execution = new ToolExecution { TaskSupport = ... } })`.

## Two server patterns

### A. Automatic — async tool returning `T`

SDK wraps the call into a task automatically when the client opts in via `CallToolRequestParams.Task`. Tool method looks normal:

```csharp
[McpServerTool, Description("Processes a large dataset")]
public static async Task<string> ProcessDataset(int count, CancellationToken ct)
{
    await Task.Delay(5000, ct);
    return $"Processed {count} records";
}
```

### B. Explicit — tool returning `McpTask`

Tool drives the lifecycle manually. SDK does NOT wrap. Required for fault-tolerant patterns (external queue / durable compute):

```csharp
[McpServerTool]
public async Task<McpTask> SubmitJob(
    string jobInput,
    RequestContext<CallToolRequestParams> context,
    CancellationToken ct)
{
    var task = await taskStore.CreateTaskAsync(
        new McpTaskMetadata { TimeToLive = TimeSpan.FromHours(24) },
        context.JsonRpcRequest.Id!,
        context.JsonRpcRequest,
        context.Server.SessionId,
        ct);

    await jobQueue.EnqueueAsync(new JobMessage { TaskId = task.TaskId, ... }, ct);
    return task;
}
```

External processor calls `taskStore.StoreTaskResultAsync(taskId, McpTaskStatus.Completed | Failed, payload, sessionId)` when done.

## Client API

```csharp
// 1. Initiate
var result = await client.CallToolAsync(new CallToolRequestParams
{
    Name = "processDataset",
    Arguments = new Dictionary<string, JsonElement> { ... },
    Task = new McpTaskMetadata { TimeToLive = TimeSpan.FromHours(2) }
}, ct);

if (result.Task is { } task)
    Console.WriteLine($"Created {task.TaskId} status={task.Status}");

// 2. Poll
var status = await client.GetTaskAsync(taskId, cancellationToken: ct);

// 3. Wait — SDK helper that polls until terminal
var completed = await client.PollTaskUntilCompleteAsync(taskId, cancellationToken: ct);

// 4. Fetch result
var json = await client.GetTaskResultAsync(taskId, cancellationToken: ct);
var ctr = json.Deserialize<CallToolResult>(McpJsonUtilities.DefaultOptions);

// Also: ListTasksAsync, CancelTaskAsync
```

### Status notifications

Optional convenience — register on `McpClientOptions.Handlers.TaskStatusHandler`:

```csharp
var options = new McpClientOptions
{
    Handlers = new McpClientHandlers
    {
        TaskStatusHandler = (task, ct) =>
        {
            Console.WriteLine($"{task.TaskId} → {task.Status}");
            return ValueTask.CompletedTask;
        }
    }
};
```

> **Doc note:** "Clients should not rely on receiving status notifications. Notifications are optional and may not be sent in all scenarios. **Always use polling as the primary mechanism.**" Treat notifications as a UI/latency optimisation, not as the state source of truth.

## Error codes

| Code | Cause |
| --- | --- |
| `InvalidParams` | Unknown taskId, invalid cursor |
| `InvalidParams` | `Forbidden` tool called with task metadata; `Required` tool called without |
| `InternalError` | Task execution failure or result unavailable |

## Fault tolerance — NOT provided by InMemory

In-memory store + automatic async-wrapping = lost on process exit. For durability you need both:

1. **Durable task state** — DB/Redis/file-backed `IMcpTaskStore`
2. **Resumable compute** — external queue/workflow engine (Service Bus, Temporal, Azure Functions, etc.)

The `FileBasedMcpTaskStore` in the LongRunningTasks sample is the simplest example. Production: durable store + queue + worker process.

---

## Delta vs ANcpLua.Agents.Mcp.Hosting.Tasks

Today's `WithInMemoryTaskStore` extension in the library:

```csharp
defaultTtl: TimeSpan.FromHours(1),    // ✓ matches doc default
maxTtl: TimeSpan.FromHours(6),        // doc default = 24h  ← differs
pollInterval: TimeSpan.FromSeconds(1),// ✓ matches
cleanupInterval: null  → "SDK default (one minute)" comment
                       // doc default = 5 minutes  ← comment wrong
maxTasks: 500                         // doc default = 1000  ← differs
// MISSING: pageSize, maxTasksPerSession
```

Plus wiring uses `Options.Configure<IMcpTaskStore>((opts, store) => opts.TaskStore = store)` — works but indirect. The canonical pattern is `AddMcpServer(opts => opts.TaskStore = store)`.

**Also missing in library:** `SendTaskStatusNotifications` toggle on `McpServerOptions`.

Action when rewriting `WithInMemoryTaskStore`:
1. Add `pageSize` + `maxTasksPerSession` params
2. Fix `cleanupInterval` default comment (5min, not 1min)
3. Reconsider `maxTtl` and `maxTasks` defaults (SDK uses 24h / 1000)
4. Add `sendStatusNotifications` param defaulting to `false` and apply to `McpServerOptions.SendTaskStatusNotifications`

## Delta vs ANcpLua.Agents.Mcp.QylMcpTaskExtensions

The client-side `RunQylToolAsTaskAsync` uses signatures from an older API surface:

```csharp
await client.CallToolAsTaskAsync(name, args, progress, ct);
await client.PollTaskUntilCompleteAsync(taskId, ct);
await client.GetTaskResultAsync(taskId, ct);
```

The 1.4.0 doc shows the canonical entry point is `CallToolAsync(CallToolRequestParams { ..., Task = new McpTaskMetadata { ... } })`, NOT a separate `CallToolAsTaskAsync` method. Verify the method still exists or is gone in 1.4.0 — if gone, rewrite to:

```csharp
var result = await client.CallToolAsync(new CallToolRequestParams
{
    Name = toolName,
    Arguments = arguments,
    Task = new McpTaskMetadata { TimeToLive = ... }
}, ct);
var taskId = result.Task!.TaskId;
var completed = await client.PollTaskUntilCompleteAsync(taskId, ct);
var resultJson = await client.GetTaskResultAsync(taskId, ct);
```

Also the doc emphasises: **progress notifications are NOT the task-progress mechanism**. Task status moves through Working → Completed via the polling path. The `IProgress<ProgressNotificationValue>` flow in `QylMcpTaskExtensions` likely targets *intra-task* progress reports (server emits during work), not task lifecycle — verify with the Progress page.

## Spec link

https://modelcontextprotocol.io/specification/draft/basic/utilities/tasks
