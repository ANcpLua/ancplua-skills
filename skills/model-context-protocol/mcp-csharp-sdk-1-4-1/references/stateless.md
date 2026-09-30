# Stateless vs Stateful — Streamable HTTP session mode

## Recommendation

**Set `Stateless` explicitly** — the SDK's current default (`false`) is expected to change. Pick based on what your server actually needs:

| Need | Mode |
| --- | --- |
| Direct server-to-client requests: sampling / elicitation / roots | **Stateful** |
| Unsolicited notifications (resource updates, async logs) | **Stateful** |
| Resource subscriptions | **Stateful** |
| Legacy SSE clients (`/sse` endpoint) | **Stateful + `EnableLegacySse = true`** |
| Per-client state isolation (parallel agents that must not share) | **Stateful** |
| Local dev where editor reset = new session | **Stateful** |
| Anything else (most servers) | **Stateless** |

```csharp
builder.Services.AddMcpServer()
    .WithHttpTransport(o => o.Stateless = true)
    .WithTools<MyTools>();
```

## What stateless removes

- `SessionId = null`, no `Mcp-Session-Id` header roundtrip
- `GET` and `DELETE` MCP endpoints are not mapped
- Legacy SSE (`/sse`, `/message`) always disabled
- Legacy direct server-to-client requests disabled: `SampleAsync`, `ElicitAsync`, `RequestRootsAsync`, server-ping
- **Unsolicited** notifications dropped (resource updates, async log messages emitted outside a handler)
- No concurrent-client isolation — every request is independent
- No state reset on reconnect (no concept of "reconnect")

## What stateless **keeps**

- **In-handler notifications** (progress, log messages emitted *during* a tool call) — written to the open POST response body, fine
- **Tasks** — work fully. Task store is shared across ephemeral server instances. Note: no session isolation, so all tasks visible across requests unless your auth layer scopes them
- **Authentication / `ClaimsPrincipal` / `[Authorize]`** — handled by ASP.NET Core middleware per-request, transport-agnostic
- **DI scopes** — uses `HttpContext.RequestServices` directly. `ScopeRequests` forced to `false`. Middleware-set scoped state is visible to handlers
- **Request cancellation** — handler `CancellationToken = HttpContext.RequestAborted`. Client disconnect = immediate cancel
- **Distributed tracing** — `traceparent`/`tracestate` propagate via `_meta`, same as stateful

## What stateful adds

- Session lifecycle: `initialize` → `Mcp-Session-Id` header → all subsequent requests carry it
- `IdleTimeout` (default 2h), `MaxIdleSessionCount` (default 10,000)
- `ConfigureSessionOptions` runs **once per session** (vs per-request in stateless)
- Per-tool-call DI scope (`ScopeRequests` defaults `true`) — fresh scope each handler
- Open GET stream channel for unsolicited messages
- Built-in **session-to-user binding**: server captures user-id claim (`NameIdentifier` / `sub` / `Upn`) on init; mismatching user on subsequent requests → 403. No config needed
- `SessionMigrationHandler` and `EventStreamStore` for HA / resumability

## Configuration knobs

```csharp
.WithHttpTransport(options =>
{
    options.Stateless = false;                  // default — set explicitly
    options.IdleTimeout = TimeSpan.FromMinutes(30);
    options.MaxIdleSessionCount = 1_000;
    options.ConfigureSessionOptions = async (httpContext, mcpServerOptions, ct) =>
    {
        var user = httpContext.User;
        if (user.IsInRole("admin"))
            mcpServerOptions.ToolCollection = [.. adminTools];
    };
})
```

In **stateless mode** `ConfigureSessionOptions` runs **on every request**, so it doubles as request-scoped tool/prompt filtering (e.g. by `X-Api-Version` header). Cheap, runs before handler dispatch.

## DI scope behaviour

| Mode | Service provider | `ScopeRequests` | Handler scope |
| --- | --- | --- | --- |
| Stateful HTTP | App services | `true` | New scope per handler invocation |
| Stateless HTTP | `HttpContext.RequestServices` | `false` (forced) | Shared HTTP request scope |
| stdio | App services | `true` (configurable) | New scope per handler invocation |

## Cancellation tokens

| Mode | Token source | Cancelled by |
| --- | --- | --- |
| Stateless HTTP | `HttpContext.RequestAborted` | Client disconnect, `ApplicationStopping` |
| Stateful Streamable HTTP | Linked: request + shutdown + session disposal | Disconnect, shutdown, idle timeout, DELETE, max-idle |
| stdio | Token passed to `RunAsync()` | stdin EOF, host shutdown |

Stateful mode: handler `CancellationToken` is **session-scoped**. A disconnected POST leaves the handler running until the session terminates. Up to `MaxStreamsPerConnection` handlers can outlive their originating connections — bounded, but real.

## Cancellation protocol

- `notifications/cancelled` — cancels a regular in-flight JSON-RPC request by id. Fire-and-forget. **Not available in stateless** (no session)
- `tasks/cancel` — required for task-augmented requests. Separate per-task cancellation token, independent of the originating HTTP request. Works in stateless

## Backpressure summary

| Config | POST held open? | Built-in limit | Risk |
| --- | --- | --- | --- |
| Stateless | Yes | `MaxStreamsPerConnection` (default 100) | Bounded |
| Stateful default | Yes | `MaxStreamsPerConnection` | Bounded |
| Legacy SSE (opt-in) | No (202 Accepted) | None | **Unbounded — apply rate limiting** |
| Stateful + `EventStreamStore` + `EnablePollingAsync()` | No | None | **Unbounded — apply rate limiting** |
| Stateful + Tasks | No (task id returned immediately) | None | **Unbounded — apply rate limiting** |

If you use the experimental Tasks feature with the in-memory store on a public-facing server, layer ASP.NET Core rate limiting and reverse-proxy limits on top.

## Observability gotcha

`mcp.session.id` activity tag = **per-instance GUID**, not the transport `Mcp-Session-Id` header. Server and client have **different** values even on the same logical session.

To correlate, add an endpoint filter that copies the header into the request Activity *before* `next()`:

```csharp
app.MapMcp().AddEndpointFilter(async (context, next) =>
{
    string? sid = context.HttpContext.Request.Headers["Mcp-Session-Id"];
    if (sid != null) Activity.Current?.AddTag("mcp.transport.session.id", sid);
    return await next(context);
});
```

In stateless this header is always null — but in that mode each request *is* the session, so the per-instance `mcp.session.id` is already the right granularity.

## MRTR note

**MRTR is not shipped in any 1.4.x package** — an earlier revision of this skill wrongly documented it as 1.4.0 surface (see `mrtr.md` for the verification and the correct 1.4.x alternatives). In 1.4.x there is no stateless-compatible path for sampling, form elicitation, or roots; only `UrlElicitationRequiredException` works statelessly.

## qyl.mcp implication

`Stateless = true` (qyl's current default) is correct unless qyl adds legacy direct server-to-client requests:
- qyl tools don't call sampling/elicitation/roots
- qyl doesn't send unsolicited notifications (UI Apps register resources but don't push updates)
- Tasks work — progress notifications inside long-running tool calls are written to the open POST stream, NOT through the GET channel
- DI scoping uses ASP.NET request scope = `IQylConstraintInjector<TScope>` resolves through `HttpContext.RequestServices` as expected
- `[Authorize]` + `AddAuthorizationFilters()` work the same — middleware populates `User` before MCP dispatch

The Stateless-blocking features (direct sampling/elicitation/roots/unsolicited notifications) are exactly the features that don't exist in qyl's tool inventory. If qyl needs interactive client input later on 1.4.x, the choices are stateful sessions or `UrlElicitationRequiredException` (browser-resolvable flows only) — MRTR only arrives with the 2.0.0-preview line.
