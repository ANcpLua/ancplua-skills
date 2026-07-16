# Filters

Two layers of pipeline interception:

1. **Message filters** — raw JSON-RPC layer, before routing. Configured via `WithMessageFilters(...)`. Methods: `AddIncomingFilter`, `AddOutgoingFilter`.
2. **Request-specific filters** — handler-level, after routing. Configured via `WithRequestFilters(...)`. One method per protocol operation.

All filters stored in `McpServerOptions.Filters`.

## Request-specific filter methods

On `IMcpRequestFilterBuilder` inside `WithRequestFilters(...)`:

- `AddListToolsFilter`, `AddCallToolFilter`
- `AddListPromptsFilter`, `AddGetPromptFilter`
- `AddListResourcesFilter`, `AddListResourceTemplatesFilter`
- `AddReadResourceFilter`
- `AddSubscribeToResourcesFilter`, `AddUnsubscribeFromResourcesFilter`
- `AddCompleteFilter`
- `AddSetLoggingLevelFilter`

## Shape

Filter = function that wraps a handler with extra behaviour. `(next) => (context, ct) => { /* before */ var r = await next(context, ct); /* after */ return r; }`

```csharp
services.AddMcpServer()
    .WithRequestFilters(rf =>
    {
        rf.AddCallToolFilter(next => async (context, ct) =>
        {
            var sw = Stopwatch.StartNew();
            var result = await next(context, ct);
            sw.Stop();
            context.Services?.GetService<ILogger<Program>>()?.LogInformation(
                "Tool {Name} took {Ms}ms", context.Params?.Name, sw.ElapsedMilliseconds);
            return result;
        });
    });
```

## Filter execution order

Registration order — first registered is outermost:

```
filter1 → filter2 → filter3 → handler → filter3 → filter2 → filter1
```

## Message filters — protocol layer

Use when you need to intercept all messages regardless of type:
- Custom protocol extensions (handle custom JSON-RPC methods)
- Log/monitor all traffic
- Modify or skip messages before they reach handlers
- Send additional messages in response to events

### Incoming

```csharp
.WithMessageFilters(mf =>
{
    mf.AddIncomingFilter(next => async (context, ct) =>
    {
        if (context.JsonRpcMessage is JsonRpcRequest req)
            log.LogInformation("Incoming: {Method}", req.Method);
        await next(context, ct);
    });
})
```

`MessageContext`:
- `JsonRpcMessage` — `JsonRpcRequest` or `JsonRpcNotification`
- `Server` — current `McpServer`
- `Services` — request service provider
- `Items` — pass-data-between-filters dictionary

### Skipping default handlers

Don't call `next` → handle the message yourself:

```csharp
mf.AddIncomingFilter(next => async (context, ct) =>
{
    if (context.JsonRpcMessage is JsonRpcRequest r && r.Method == "custom/myMethod")
    {
        await context.Server.SendMessageAsync(new JsonRpcResponse
        {
            Id = r.Id,
            Result = JsonSerializer.SerializeToNode(new { message = "Custom" })
        }, ct);
        return;  // don't call next
    }
    await next(context, ct);
});
```

### Outgoing — inspect / suppress / inject

```csharp
.WithMessageFilters(mf =>
{
    mf.AddOutgoingFilter(next => async (context, ct) =>
    {
        // Suppress
        if (context.JsonRpcMessage is JsonRpcNotification n && n.Method == "notifications/progress")
            return;
        await next(context, ct);
    });
})
```

### Order

Message filters always run **before** request-specific filters. Full per-cycle order:

```
Request arrives
  → IncomingFilter1 → IncomingFilter2 → request routing → ListToolsFilter → handler
  → response → OutgoingFilter1 → OutgoingFilter2 → transport
```

## Built-in `AddAuthorizationFilters()`

Adds the SDK's authorisation pipeline that respects `[Authorize]` / `[AllowAnonymous]` attributes. Order matters — filters registered *before* see all requests, after see only authorised. See `identity.md` for full details.

```csharp
services.AddMcpServer()
    .WithHttpTransport(o => o.Stateless = true)
    .AddAuthorizationFilters()
    .WithTools<MyTools>();
```

## RequestContext properties available in filters

- `context.User` — `ClaimsPrincipal` (transport-agnostic)
- `context.Services` — request service provider (for `GetService<ILogger<...>>`, `IMemoryCache`, etc.)
- `context.MatchedPrimitive` — matched tool / prompt / resource with metadata (incl. authorisation attributes via `MatchedPrimitive.Metadata`)
- `context.Items` — filter-to-filter dictionary

## Common patterns

### Caching

```csharp
rf.AddListResourcesFilter(next => async (ctx, ct) =>
{
    var cache = ctx.Services!.GetRequiredService<IMemoryCache>();
    var key = $"resources:{ctx.Params.Cursor}";
    if (cache.TryGetValue(key, out var hit)) return (ListResourcesResult)hit!;
    var result = await next(ctx, ct);
    cache.Set(key, result, TimeSpan.FromMinutes(5));
    return result;
});
```

### Error wrapping (graceful failure for clients)

```csharp
rf.AddCallToolFilter(next => async (ctx, ct) =>
{
    try { return await next(ctx, ct); }
    catch (Exception ex)
    {
        ctx.Services?.GetService<ILogger<Program>>()?
           .LogError(ex, "Error in {ProgressToken}", ctx.Params?.ProgressToken);
        return new CallToolResult
        {
            Content = [new TextContentBlock { Text = "Unexpected tool error." }],
            IsError = true
        };
    }
});
```

This produces an error result the LLM can read — better than letting the SDK return the generic "An error occurred invoking '...'."

### Argument rewriting (per-request scope injection)

```csharp
rf.AddCallToolFilter(next => async (ctx, ct) =>
{
    var scope = ctx.Services?.GetService<TScope>();
    if (scope is not null && ctx.Params is { } p)
        p.Arguments = injector.Inject(p.Arguments, scope);
    return await next(ctx, ct);
});
```

(This is the canonical home for qyl's `IQylConstraintInjector` pattern.)

## Filter vs Handler vs Authorize attribute — when to use which

| Want | Use |
| --- | --- |
| Role/policy-gated tool | `[Authorize(Roles=...)]` + `AddAuthorizationFilters()` |
| Per-call argument transform | Request filter (`AddCallToolFilter`) |
| Per-call logging / timing / metrics | Request filter |
| Cache list result | Request filter (`AddListToolsFilter` etc.) |
| Replace default behaviour entirely | Custom handler via `McpServerHandlers` |
| Intercept all JSON-RPC traffic | Message filter |
| Handle custom protocol method | Message filter (skip `next`) |
