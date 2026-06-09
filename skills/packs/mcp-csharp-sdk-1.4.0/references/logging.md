# Logging

Servers can emit log messages to connected clients via `notifications/message`. Uses RFC 5424 levels.

> **Stateful or stdio.** In stateless mode there's no open channel for unsolicited messages — `notifications/message` won't reach the client.

## Levels — MCP vs .NET ILogger mapping

| MCP | .NET | Use |
| --- | --- | --- |
| debug | ✓ | Detail / entry-exit |
| info | ✓ | Progress / state |
| notice | — | Significant events (config change) |
| warning | ✓ | Warnings |
| error | ✓ | Errors |
| critical | ✓ | Component failure |
| alert | — | Immediate action required |
| emergency | — | System unusable |

`Trace` exists in .NET but has no MCP equivalent — **trace logs are silently dropped** when forwarded to the client.

## Server side

Capability is auto-declared by all C# SDK servers (declaring it doesn't obligate emission).

Get an `ILoggerProvider` that routes to the connected client:

```csharp
[McpServerTool]
public static async Task<string> DoWork(McpServer server, CancellationToken ct)
{
    var loggerProvider = server.AsClientLoggerProvider();
    var log = loggerProvider.CreateLogger("MyTool");

    log.LogInformation("Starting work");          // → notifications/message to client
    // ...
    log.LogWarning("Slow operation detected");
    return "done";
}
```

The server filters by the client-requested level (set via `SetLoggingLevelAsync`). Messages below that level are dropped server-side.

Optional handler to react to client level changes:

```csharp
builder.Services.AddMcpServer()
    .WithSetLoggingLevelHandler(async (ctx, ct) =>
    {
        // ctx.Params.Level = the new level
        // ctx.Server.LoggingLevel is also set by the SDK automatically
        return new EmptyResult();
    });
```

Most servers don't need this — the SDK updates `server.LoggingLevel` for you.

## Client side

```csharp
if (mcpClient.ServerCapabilities?.Logging is null) return;

// 1. Set the threshold
await mcpClient.SetLoggingLevelAsync(LoggingLevel.Info);

// 2. Register handler
mcpClient.RegisterNotificationHandler(
    NotificationMethods.LoggingMessageNotification,
    (notification, ct) =>
    {
        if (JsonSerializer.Deserialize<LoggingMessageNotificationParams>(notification.Params) is { } ln)
            Console.WriteLine($"[{ln.Level}] {ln.Logger}: {ln.Data}");
        return default;
    });
```

If the client doesn't `SetLoggingLevelAsync`, server behaviour is unspecified — might send everything, might send nothing. Always set explicitly.

## Stateless caveat

Stateless servers cannot emit `notifications/message` because there's no GET channel for unsolicited delivery. For stateless hosts that want to emit info/error to **stderr** (e.g. observability via container logs), use ASP.NET Core's normal logging providers — they don't route through MCP. The MCP logging facility is specifically for **delivering messages to the connected client**.

## Stdio convention

Stdio servers MUST keep `stdout` exclusive to JSON-RPC framing. Console logger → `stderr` only:

```csharp
builder.Logging.AddConsole(opts => opts.LogToStandardErrorThreshold = LogLevel.Trace);
```

Without this, any console log corrupts the protocol stream and disconnects the client.
