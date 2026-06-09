# Progress tracking

> **Key fact:** progress notifications are sent **inline as part of the response to the originating request** — they are not unsolicited. They work in **stateless, stateful, and stdio** alike.

This is why a stateless server can still emit progress: the notification is written into the open POST response body alongside the eventual JSON-RPC response, not via the (non-existent) GET channel.

## Server side

Tool method takes `McpServer` (auto-injected from DI):

```csharp
[McpServerTool, Description("Long task with progress")]
public static async Task<string> DoWork(
    McpServer server,
    int steps,
    ProgressToken? progressToken,   // null if client didn't request progress
    CancellationToken ct)
{
    for (int i = 1; i <= steps; i++)
    {
        await Task.Delay(1000, ct);

        if (progressToken is not null)
        {
            await server.SendNotificationAsync("notifications/progress",
                new ProgressNotificationParams
                {
                    ProgressToken = progressToken.Value,
                    Progress = new ProgressNotificationValue
                    {
                        Progress = i,
                        Total = steps,
                        Message = $"Step {i}/{steps}"
                    }
                });
        }
    }
    return $"Done after {steps} steps.";
}
```

Servers must include the **caller-supplied** `progressToken` so the client can correlate. No token → don't emit.

## Client side — two ways to receive

### A. `Progress<T>` parameter — recommended for single-call use

Filtered automatically to the originating request:

```csharp
var handler = new Progress<ProgressNotificationValue>(v =>
    Console.WriteLine($"{v.Progress}/{v.Total} - {v.Message}"));

var result = await mcpClient.CallToolAsync(
    name: "doWork",
    progress: handler,
    cancellationToken: ct);
```

The SDK assigns the `progressToken`, plumbs it into the request, and routes inbound progress notifications matching that token to your `Progress<T>` instance. No filtering on your side.

### B. `RegisterNotificationHandler` — for global / multi-call interception

Receives **all** progress notifications. You filter by token yourself:

```csharp
await using var sub = mcpClient.RegisterNotificationHandler(
    NotificationMethods.ProgressNotification,
    (notification, ct) =>
    {
        var pn = JsonSerializer.Deserialize<ProgressNotificationParams>(notification.Params);
        if (pn?.ProgressToken == myToken)
            Console.WriteLine($"{pn.Progress.Progress}/{pn.Progress.Total}");
        return ValueTask.CompletedTask;
    });
```

Use when you want a single observer for multiple in-flight calls, or for cross-cutting telemetry.

## Important client caveats

- Servers are **not required** to support progress. Don't assume notifications will arrive.
- `Progress<T>` instances dispatch on the thread context captured at construction time — be careful if you construct on UI thread.

## qyl.mcp implication for `QylMcpTaskExtensions.RunQylToolAsTaskAsync`

Today's extension registers an `IProgress<ProgressNotificationValue>` and passes it via `CallToolAsTaskAsync(toolName, args, progress: ..., ct)`. That's pattern A and is correct in principle.

Two things to verify against the SDK in 1.4.0:
1. Does `CallToolAsTaskAsync(toolName, args, IProgress<>, ct)` exist as a method, or has it been replaced by `CallToolAsync(CallToolRequestParams { ..., Task = ... })` with progress passed separately? See `tasks.md` — the canonical 1.4.0 task entry is `CallToolAsync` with `Task` metadata, not a separate method.
2. The bridge currently emits `mcp.task.progress` ActivityEvents. This conflates two things: task lifecycle (Working → Completed) and intra-task progress. They are distinct in the SDK — progress fires via `notifications/progress`, task status via `tasks/status`. Consider separating the two event sources.
