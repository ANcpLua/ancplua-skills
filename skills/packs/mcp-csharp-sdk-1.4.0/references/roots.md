# Roots

Client tells the server which filesystem / hierarchical URIs are "relevant" to the session — project directories, repositories, scoped workspaces.

> Direct `RequestRootsAsync` requires stateful HTTP or stdio. Stateless-compatible roots requests use MRTR; see `mrtr.md`.

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

## MRTR alternative in 1.4.0

`DRAFT-2026-v1` removes the legacy Streamable HTTP `roots/list` server-to-client request. For tools that must work in stateless HTTP or draft protocol, throw `InputRequiredException`:

```csharp
if (context.Params?.InputResponses?.TryGetValue("get_roots", out var response) is true)
{
    var roots = response.Deserialize(InputResponse.ListRootsResultJsonTypeInfo);
    return string.Join("\n", roots?.Roots.Select(r => $"- {r.Name ?? r.Uri}") ?? Array.Empty<string>());
}

if (!server.IsMrtrSupported)
    return "This tool requires MRTR support.";

throw new InputRequiredException(
    inputRequests: new Dictionary<string, InputRequest>
    {
        ["get_roots"] = InputRequest.ForRootsList(new ListRootsRequestParams())
    });
```

Use `server.IsMrtrSupported` before throwing. Current stable stateless sessions cannot resolve MRTR; draft sessions can.
