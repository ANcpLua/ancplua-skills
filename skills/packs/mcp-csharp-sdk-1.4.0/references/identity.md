# Identity and Roles

## Flow

```
HTTP request with auth token
 → ASP.NET Core auth middleware (sets HttpContext.User)
 → MCP transport copies into JsonRpcMessage.Context.User
 → Message filters (context.User)
 → Request filters (context.User)
 → Tool / prompt / resource handler (ClaimsPrincipal parameter)
```

## Recommended pattern — `ClaimsPrincipal` parameter

SDK auto-injects, excludes from JSON schema, returns `null` when unauthenticated (if nullable):

```csharp
[McpServerToolType]
public class UserAwareTools
{
    [McpServerTool, Description("Returns a personalized greeting.")]
    public string Greet(ClaimsPrincipal? user, string message)
        => $"{user?.Identity?.Name ?? "anonymous"}: {message}";
}
```

Works identically on tools, prompts, resources. **Transport-agnostic** — HTTP wires it from `HttpContext.User`; stdio leaves it null unless a message filter sets it.

## Access from filters

```csharp
.WithRequestFilters(rf => rf.AddCallToolFilter(next => async (context, ct) =>
{
    var name = context.User?.Identity?.Name;
    // log, audit, decide
    return await next(context, ct);
}));
```

## Declarative authorization — `AddAuthorizationFilters()`

Enables `[Authorize]` / `[AllowAnonymous]` on tool methods and tool-type classes:

```csharp
services.AddMcpServer()
    .WithHttpTransport()
    .AddAuthorizationFilters()
    .WithTools<RoleProtectedTools>();
```

```csharp
[McpServerToolType]
public class RoleProtectedTools
{
    [McpServerTool, Authorize]                     // any auth'd user
    public string GetData(string query) => $"Data: {query}";

    [McpServerTool, Authorize(Roles = "Admin")]    // admin only
    public string AdminOp(string action) => $"Admin: {action}";

    [McpServerTool, AllowAnonymous]                // public, overrides class-level [Authorize]
    public string PublicInfo() => "public";
}
```

`[Authorize(Roles=...)]`, `[Authorize(Policy=...)]` all supported. Class-level `[Authorize]` applies to every method unless overridden by `[AllowAnonymous]`.

### Behaviour difference: list vs individual ops

| Operation | On unauthorized |
| --- | --- |
| `tools/list`, `prompts/list`, `resources/list` | Item silently removed from result |
| `tools/call`, `prompts/get`, `resources/read` | JSON-RPC error "Access forbidden" |

The list-filter behaviour is auto and is what makes `[Authorize]` superior to a hand-rolled call-tool filter: callers see only the tools they can invoke.

### Filter execution order

Filters registered *before* `AddAuthorizationFilters()` see all requests / full listings; filters registered *after* see authorized-only. Use this to log unauthorized attempts:

```csharp
.WithRequestFilters(rf => rf.AddListToolsFilter(/* sees all */))
.AddAuthorizationFilters()
.WithRequestFilters(rf => rf.AddListToolsFilter(/* sees filtered */))
```

## HTTP-only escape hatch — `IHttpContextAccessor`

Inject when you need `HttpContext` (headers, query string) not just user:

```csharp
[McpServerToolType]
public class HttpContextTools(IHttpContextAccessor accessor)
{
    [McpServerTool]
    public string GetFilteredData(string query)
    {
        var ctx = accessor.HttpContext ?? throw new InvalidOperationException();
        return $"{ctx.User.Identity?.Name}: {query}";
    }
}
```

**Caveat:** legacy SSE transport ties `HttpContext` to the long-lived GET connection — token refreshes after connection-open won't appear via `IHttpContextAccessor`. The `ClaimsPrincipal` parameter does see fresh claims (re-read per POST).

## Stdio identity

No HTTP auth. Set in a message filter from environment / process context:

```csharp
.WithMessageFilters(mf => mf.AddIncomingFilter(next => async (context, ct) =>
{
    var role = Environment.GetEnvironmentVariable("MCP_USER_ROLE") ?? "default";
    context.User = new ClaimsPrincipal(new ClaimsIdentity(
        [new Claim(ClaimTypes.Name, "stdio-user"),
         new Claim(ClaimTypes.Role, role)],
        "StdioAuth", ClaimTypes.Name, ClaimTypes.Role));
    await next(context, ct);
}));
```

After this, `[Authorize(Roles=...)]` and `ClaimsPrincipal` injection both work over stdio.

## Transport summary

| Transport | Source | Note |
| --- | --- | --- |
| Streamable HTTP | ASP.NET Core auth middleware → `HttpContext.User` | Fresh per request |
| SSE (legacy) | Same, tied to long-lived GET conn | `IHttpContextAccessor` may be stale |
| stdio | `null` unless set in filter | Use env vars / process context |

## qyl.mcp implication

`WithQylAdminFilter` + `QylAdminFilterOptions` + `QylMcpAdminFilter` re-invent `AddAuthorizationFilters()` with less coverage:
- Custom filter only handles `tools/call`; misses list-time filtering (user sees admin tools they can't call)
- Hand-rolled role resolution duplicates what ASP.NET Core auth already does
- `QylAdminTools.Names = FrozenSet<string>.Empty` — currently no tools gated, the filter is dead plumbing

**Drop from library:** `Filters/QylAdminFilterOptions.cs`, `Filters/QylMcpAdminFilter.cs`.
**Drop from qyl.mcp:** `QylAdminTools`, `McpAuthRoles`, the `WithQylAdminFilter(...)` chain call.
**Replace with:** `AddAuthorizationFilters()` chain call + `[Authorize(Roles = "qyl:admin")]` on admin tools when they exist.

Stateless mode is fine — auth middleware runs per-request, `ClaimsPrincipal` is populated normally. Same for stdio if a filter sets `context.User`.

## Spec / sample

Complete end-to-end example with JWT + protected-resource metadata: https://github.com/modelcontextprotocol/csharp-sdk/tree/main/samples/ProtectedMcpServer
