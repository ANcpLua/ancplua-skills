# Roots

Client tells the server which filesystem / hierarchical URIs are "relevant" to the session — project directories, repositories, scoped workspaces.

> `RequestRootsAsync` requires stateful HTTP or stdio. **1.4.x has no stateless-compatible roots path** — MRTR is not shipped in 1.4.x (see `mrtr.md`).

## Why

A server can scope file ops to user-relevant locations without hardcoding paths:
- File-search tools only look under declared roots
- Repository-aware tools learn which repo is "current"
- Filesystem-boundary enforcement for safety

## Client — declaring roots

Setting `RootsHandler` auto-advertises the capability:

```csharp
var options = new McpClientOptions
{
    Handlers = new McpClientHandlers
    {
        RootsHandler = (request, ct) => ValueTask.FromResult(new ListRootsResult
        {
            Roots =
            [
                new Root { Uri = "file:///home/user/projects/my-app", Name = "My App" },
                new Root { Uri = "file:///home/user/projects/shared", Name = "Shared Lib" }
            ]
        })
    }
};
```

`Root` = URI + optional human-readable `Name`.

## Server — fetching roots

```csharp
[McpServerTool]
public static async Task<string> ListProjectRoots(McpServer server, CancellationToken ct)
{
    var result = await server.RequestRootsAsync(new ListRootsRequestParams(), ct);
    return string.Join("\n", result.Roots.Select(r => $"- {r.Name ?? r.Uri}"));
}
```

## Change notifications

When roots change (user opens another project), the client sends `notifications/roots/list_changed`:

```csharp
// Client
await mcpClient.SendNotificationAsync(
    NotificationMethods.RootsListChangedNotification,
    new RootsListChangedNotificationParams());
```

```csharp
// Server
server.RegisterNotificationHandler(
    NotificationMethods.RootsListChangedNotification,
    async (notification, ct) =>
    {
        var result = await server.RequestRootsAsync(new ListRootsRequestParams(), ct);
        // update internal state
    });
```

## Capability check

```csharp
if (server.ClientCapabilities?.Roots is null) { /* roots not supported */ }
```

## No stateless roots in 1.4.x

There is no MRTR / `InputRequiredException` path in any shipped 1.4.x package (`mrtr.md` has the verification). A tool that needs client filesystem roots must run under a stateful HTTP session or stdio. In stateless deployments, accept the relevant paths as explicit tool parameters instead.
