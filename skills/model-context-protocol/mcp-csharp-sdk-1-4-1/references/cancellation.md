# Cancellation

Bidirectional, both sides can cancel in-flight requests. `CancellationToken` arguments on SDK methods are wired to the MCP `notifications/cancelled` protocol notification.

## Flow

1. Client's `CallToolAsync(..., ct)` is invoked
2. Caller cancels the `CancellationTokenSource` backing `ct`
3. SDK sends `notifications/cancelled { requestId, reason? }` to server
4. Server's handler `CancellationToken` (the one passed to the tool method) fires
5. Handler should propagate it to all `await`s — `Task.Delay(time, ct)`, `HttpClient.GetAsync(url, ct)`, etc.
6. `OperationCanceledException` propagates back to the client as a cancellation response

Identical flow in reverse for server-to-client requests.

## Server-side tool

```csharp
[McpServerTool]
public static async Task<string> LongComputation(int iterations, CancellationToken ct)
{
    for (int i = 0; i < iterations; i++)
        await Task.Delay(1000, ct);  // ← passes ct, so cancellation surfaces
    return $"Done {iterations}.";
}
```

`OperationCanceledException` is re-thrown by the SDK (not converted to `IsError = true` like other exceptions — see `tools.md`).

## Observing cancellation notifications

For audit / telemetry, register a notification handler:

```csharp
mcpClient.RegisterNotificationHandler(
    NotificationMethods.CancelledNotification,
    (notification, ct) =>
    {
        var c = notification.Params?.Deserialize<CancelledNotificationParams>(McpJsonUtilities.DefaultOptions);
        if (c is not null)
            Console.WriteLine($"Request {c.RequestId} cancelled: {c.Reason}");
        return default;
    });
```

Or via message filter (`IncomingFilters`) for broader interception.

## Cancellation under different session modes

See `stateless.md` for full details:

| Mode | Handler `CancellationToken` source |
| --- | --- |
| Stateless HTTP | `HttpContext.RequestAborted` — client disconnect cancels immediately |
| Stateful Streamable HTTP | Linked: request + shutdown + session disposal. Disconnected POST does **not** cancel a running handler — handler runs until session ends |
| stdio | Token passed to `RunAsync()` |

## Tasks have a separate cancellation channel

For task-augmented requests, spec **requires** using `tasks/cancel` (request/response) rather than `notifications/cancelled` (fire-and-forget). The SDK uses a per-task token independent of the originating HTTP request, so `tasks/cancel` works even after the initial request has completed.

```csharp
var cancelledTask = await client.CancelTaskAsync(taskId, cancellationToken: ct);
```

In stateless mode `notifications/cancelled` doesn't apply (no persistent session); regular request cancellation is purely via `HttpContext.RequestAborted` propagation from the client side.
