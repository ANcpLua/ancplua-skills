# Transports

Three transport mechanisms: **stdio**, **Streamable HTTP**, **SSE** (legacy, deprecated).

## stdio

Child-process pattern — client launches server, communicates over stdin/stdout. Best for local integrations (IDEs, CLIs, single-user tools).

### Client

```csharp
var transport = new StdioClientTransport(new StdioClientTransportOptions
{
    Command = "dnx",
    Arguments = ["NuGet.Mcp.Server"],
    ShutdownTimeout = TimeSpan.FromSeconds(10)
});
await using var client = await McpClient.CreateAsync(transport);
```

`StdioClientTransportOptions`:

| Property | Meaning |
| --- | --- |
| `Command` | Executable to launch (required) |
| `Arguments` | Command-line args |
| `WorkingDirectory` | CWD for the child process |
| `EnvironmentVariables` | Merged with current. `null` value **removes** an inherited var |
| `ShutdownTimeout` | Graceful shutdown window (default 5s) |
| `StandardErrorLines` | Callback for child-process stderr lines |
| `Name` | Transport identifier for logging |

### Server

```csharp
var builder = Host.CreateApplicationBuilder(args);
builder.Services.AddMcpServer()
    .WithStdioServerTransport()
    .WithTools<MyTools>();
await builder.Build().RunAsync();
```

> **stdout discipline:** route all console logs to stderr (`builder.Logging.AddConsole(o => o.LogToStandardErrorThreshold = LogLevel.Trace)`). Any byte on stdout outside JSON-RPC framing corrupts the stream.

## Streamable HTTP

The recommended remote transport. Bidirectional, optional streaming, session-aware.

### Client

```csharp
var transport = new HttpClientTransport(new HttpClientTransportOptions
{
    Endpoint = new Uri("https://my-mcp-server.example.com/mcp"),
    TransportMode = HttpTransportMode.StreamableHttp,
    ConnectionTimeout = TimeSpan.FromSeconds(30),
    AdditionalHeaders = new() { ["X-Custom-Header"] = "value" }
});
await using var client = await McpClient.CreateAsync(transport);
```

### Auto-detect mode

`HttpTransportMode.AutoDetect` (default): tries Streamable HTTP first, falls back to legacy SSE. Set `StreamableHttp` explicitly when you know the server supports it — saves a probe.

### Session resumption

```csharp
var transport = new HttpClientTransport(new HttpClientTransportOptions
{
    Endpoint = new Uri("https://my-mcp-server.example.com/mcp"),
    KnownSessionId = previousSessionId
});

await using var client = await McpClient.ResumeSessionAsync(transport, new ResumeClientSessionOptions
{
    ServerCapabilities = previousServerCapabilities,
    ServerInfo = previousServerInfo
});
```

Useful when the client process restarts but the server session is still alive, or to hand off a session between components.

### Server (ASP.NET Core)

```csharp
var builder = WebApplication.CreateBuilder(args);
builder.Services.AddMcpServer()
    .WithHttpTransport(o => o.Stateless = true)   // recommended — see stateless.md
    .WithTools<MyTools>();
var app = builder.Build();
app.MapMcp();
app.Run();
```

`MapMcp(pattern = "/")` — root by default. Pass a path string to mount elsewhere.

### Stateless vs Stateful

`Stateless = true` is the recommended default. See full guidance in `stateless.md`. **Set explicitly** — the SDK's current default (`false`) is expected to change.

### Protocol version header

Streamable HTTP carries the negotiated version in `MCP-Protocol-Version`. SDK 1.4.0's latest stable protocol is `2025-11-25`; draft MRTR uses `DRAFT-2026-v1`.

Client opt-in:

```csharp
await using var client = await McpClient.CreateAsync(
    transport,
    new McpClientOptions { ProtocolVersion = "DRAFT-2026-v1" });
```

The draft also gates stricter HTTP-standardization behavior, including standard request headers such as `Mcp-Method`, `Mcp-Name`, and `Mcp-Param-*` values emitted from `[McpHeader]`.

### Host name validation

Kestrel doesn't validate `Host` headers by default — vulnerable to DNS rebinding. Configure `AllowedHosts` to known host names (never `"*"`).

### Cross-origin browser access

CORS off by default. If you need browser cross-origin requests, configure the most restrictive policy possible — CORS is **not** a substitute for host validation.

## Legacy SSE

Disabled by default in 1.4.0 (`EnableLegacySse = false`, marked `[Obsolete]` with diagnostic `MCP9004`). Endpoints: `/sse` (long-lived GET) and `/message` (POST returns `202 Accepted`).

### Why disabled

No HTTP-level backpressure: each POST returns immediately, handler runs fire-and-forget. Easy to overload.

### Migration path

Client-side: change `Endpoint` from `/sse` URL to the root MCP URL. `AutoDetect` mode handles the transport switch.

Server-side: enable `EnableLegacySse = true` (suppress `MCP9004`) only if you have clients you can't migrate yet. Once they're all on Streamable HTTP, remove the flag.

`EnableLegacySse = true` is incompatible with `Stateless = true` — throws `InvalidOperationException` at startup.
