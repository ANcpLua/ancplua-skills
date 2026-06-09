# HTTP Context

Direct access to `HttpContext` from tools / prompts / resources — headers, query string, path, raw request metadata.

> HTTP-only. Stdio has no `HttpContext`. For transport-agnostic identity, use the `ClaimsPrincipal` parameter — see `identity.md`.

## Setup

```csharp
builder.Services.AddHttpContextAccessor();
```

## Inject into tool classes

```csharp
public class ContextTools(IHttpContextAccessor accessor)
{
    [McpServerTool(UseStructuredContent = true)]
    [Description("Returns the request headers")]
    public object GetHttpHeaders()
    {
        var ctx = accessor.HttpContext;
        if (ctx is null) return "No HTTP context available";

        return ctx.Request.Headers
            .ToDictionary(h => h.Key, h => string.Join(", ", h.Value.ToArray()));
    }
}
```

Constructor injection on the tool-class itself. Don't add `IHttpContextAccessor` as a tool-method parameter — that would put it in the JSON schema.

## When you need it (vs `ClaimsPrincipal` injection)

| Need | Use |
| --- | --- |
| Just the authenticated user | `ClaimsPrincipal? user` tool parameter — auto-injected, transport-agnostic |
| Header value, route value, raw query string | `IHttpContextAccessor` |
| Forwarded headers (`X-Forwarded-For`, `X-Real-IP`) | `IHttpContextAccessor` |
| Tenant routing from path segment | `IHttpContextAccessor` |

## Important caveats

- **Legacy SSE transport**: `HttpContext` is tied to the long-lived GET stream; values like `Request.Headers["Authorization"]` may be stale if the client refreshed the token after connection. `ClaimsPrincipal` parameter is re-read per-POST so it's always fresh.
- **`PerSessionExecutionContext = true`**: Using this option on the HTTP transport breaks `IHttpContextAccessor` because the execution context is captured at session creation, not per request. Avoid combining the two.
- **Stateless mode**: works normally — each request creates a fresh server context and `IHttpContextAccessor.HttpContext` reflects that request.
