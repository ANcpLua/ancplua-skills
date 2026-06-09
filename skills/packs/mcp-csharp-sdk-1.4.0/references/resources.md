# Resources

Server-exposed data — files, DB records, API responses, live system data. Clients list and read; can optionally subscribe to updates.

## Definition patterns

Same five mechanisms as Tools / Prompts:
- `[McpServerResourceType]` + `[McpServerResource]` attributes (most common)
- `McpServerResource.Create*` factories (delegate / `MethodInfo` / `AIFunction`)
- Derive from `McpServerResource` or `DelegatingMcpServerResource`
- Custom `McpRequestHandler<TParams, TResult>` via `McpServerHandlers`
- Low-level `McpRequestFilter<TParams, TResult>`

## Direct resource (fixed URI)

Returned in `resources/list`:

```csharp
[McpServerResourceType]
public class MyResources
{
    [McpServerResource(UriTemplate = "config://app/settings", Name = "App Settings", MimeType = "application/json")]
    [Description("Application configuration")]
    public static string GetSettings() =>
        JsonSerializer.Serialize(new { theme = "dark", language = "en" });
}
```

## Template resource (RFC 6570 URI templates)

Returned in `resources/templates/list`, matches a range of URIs:

```csharp
[McpServerResource(UriTemplate = "docs://articles/{id}", Name = "Article")]
public static ResourceContents GetArticle(string id)
{
    var text = LoadArticle(id) ?? throw new McpException($"Article not found: {id}");
    return new TextResourceContents
    {
        Uri = $"docs://articles/{id}",
        MimeType = "text/plain",
        Text = text
    };
}
```

Register:

```csharp
builder.Services.AddMcpServer()
    .WithHttpTransport()
    .WithResources<MyResources>()
    .WithResources<DocumentResources>();
```

## Content types

- `TextResourceContents` — `Uri`, `MimeType`, `Text`
- `BlobResourceContents` — `Uri`, `MimeType`, `Blob` (raw bytes). Use `BlobResourceContents.FromBytes(bytes, uri, mime)`

```csharp
[McpServerResource(UriTemplate = "images://photos/{id}", Name = "Photo")]
public static BlobResourceContents GetPhoto(int id) =>
    BlobResourceContents.FromBytes(LoadPhoto(id), $"images://photos/{id}", "image/png");
```

## Client — listing and reading

```csharp
var resources = await client.ListResourcesAsync();
var templates = await client.ListResourceTemplatesAsync();

// Direct URI
var result = await client.ReadResourceAsync("config://app/settings");

// Template with params
var result = await client.ReadResourceAsync(
    "docs://articles/{id}",
    new Dictionary<string, object?> { ["id"] = "intro" });

foreach (var content in result.Contents)
{
    switch (content)
    {
        case TextResourceContents t: Console.WriteLine($"[{t.MimeType}] {t.Text}"); break;
        case BlobResourceContents b: Console.WriteLine($"[{b.MimeType}] {b.Blob.Length} bytes"); break;
    }
}
```

## Subscriptions — change tracking per-URI

Requires server to declare `Resources = { Subscribe: true }` capability.

### Client

```csharp
IAsyncDisposable sub = await client.SubscribeToResourceAsync(
    "config://app/settings",
    async (notification, ct) =>
    {
        var fresh = await client.ReadResourceAsync(notification.Uri, cancellationToken: ct);
        // process update
    });

// or separately:
await client.SubscribeToResourceAsync("config://app/settings");
// ... use global RegisterNotificationHandler for ResourceUpdatedNotification ...
await client.UnsubscribeFromResourceAsync("config://app/settings");
```

### Server

Wire handlers and emit notifications when a resource changes:

```csharp
builder.Services.AddMcpServer()
    .WithResources<MyResources>()
    .WithSubscribeToResourcesHandler(async (ctx, ct) =>
    {
        if (ctx.Params?.Uri is { } uri)
            subscriptions[ctx.Server.SessionId].TryAdd(uri, 0);
        return new EmptyResult();
    })
    .WithUnsubscribeFromResourcesHandler(async (ctx, ct) =>
    {
        if (ctx.Params?.Uri is { } uri)
            subscriptions[ctx.Server.SessionId].TryRemove(uri, out _);
        return new EmptyResult();
    });

// When resource changes:
await server.SendNotificationAsync(
    NotificationMethods.ResourceUpdatedNotification,
    new ResourceUpdatedNotificationParams { Uri = "config://app/settings" });
```

> **Stateful only** — `notifications/resources/updated` is unsolicited (no in-flight request triggered it). Disabled in stateless. Stateful + GET channel required.

## Resource-list change notifications

```csharp
// Server
await server.SendNotificationAsync(
    NotificationMethods.ResourceListChangedNotification,
    new ResourceListChangedNotificationParams());
```

```csharp
// Client
mcpClient.RegisterNotificationHandler(
    NotificationMethods.ResourceListChangedNotification,
    async (notification, ct) =>
    {
        var fresh = await mcpClient.ListResourcesAsync(cancellationToken: ct);
    });
```

Also stateful-only (unsolicited).

## qyl.mcp UI Apps pattern

qyl uses resources for UI Apps:
- `UriTemplate = "ui://qyl/error-explorer"` (Anthropic MCP UI Apps convention)
- `MimeType = "text/html;profile=mcp-app"`

That pattern stays valid in 1.4.0 — direct resources with HTML content. The MIME profile is purely a client-side hint (Anthropic uses it to recognise renderable UI). No SDK changes touch it.
