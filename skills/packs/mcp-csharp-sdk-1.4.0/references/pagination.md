# Pagination

Cursor-based pagination for all MCP list operations. Cursor tokens are **opaque** to the client.

## Two API levels

### Convenience — auto-paginate

`McpClient` convenience methods return `IList<T>` of all results, transparently fetching all pages:

```csharp
IList<McpClientTool>             tools     = await client.ListToolsAsync();
IList<McpClientResource>         resources = await client.ListResourcesAsync();
IList<McpClientPrompt>           prompts   = await client.ListPromptsAsync();
IList<McpClientResourceTemplate> templates = await client.ListResourceTemplatesAsync();
```

### Manual — explicit cursor

For page-by-page processing or bounded fetches:

```csharp
string? cursor = null;
do
{
    var result = await client.ListToolsAsync(new ListToolsRequestParams { Cursor = cursor });
    foreach (var tool in result.Tools) /* process */;
    cursor = result.NextCursor;  // null when no more pages
}
while (cursor is not null);
```

## Server — custom list handler with pagination

Cursor format is your choice — opaque to caller. Number, base64, opaque token, anything:

```csharp
builder.Services.AddMcpServer()
    .WithListResourcesHandler(async (ctx, ct) =>
    {
        const int pageSize = 10;
        int start = ctx.Params?.Cursor is { } c ? int.Parse(c) : 0;

        var all = GetAllResources();
        var page = all.Skip(start).Take(pageSize).ToList();
        var hasMore = start + pageSize < all.Count;

        return new ListResourcesResult
        {
            Resources = page,
            NextCursor = hasMore ? (start + pageSize).ToString() : null
        };
    });
```

## Edge cases

- **`NextCursor = null`** → no more pages
- **`NextCursor = ""`** (empty string) → spec ambiguity: technically signals "more available" because *any* value is treated as a continuation. Bug-prone — never emit empty string on the final page. Clients can defensively detect empty-string cursors and stop.

## Default behaviour

The SDK's built-in list handlers (driven by `WithTools<T>()`, `WithResources<T>()`, `WithPrompts<T>()`) return all registered items in a single response with `NextCursor = null`. Pagination only matters when you implement custom list handlers that need to chunk large collections.
