# Capabilities

Capabilities are negotiated during `initialize`. Both sides declare what they support; before using an optional feature, check the other side advertised it.

## Client capabilities — `ClientCapabilities`

| Capability | Type | Meaning |
| --- | --- | --- |
| `Roots` | `RootsCapability` | Client provides filesystem root URIs |
| `Sampling` | `SamplingCapability` | Client handles LLM sampling requests |
| `Elicitation` | `ElicitationCapability` | Client renders forms / opens URLs |
| `Experimental` | `IDictionary<string, object>` | Vendor extensions |

```csharp
var options = new McpClientOptions
{
    Capabilities = new ClientCapabilities
    {
        Roots = new RootsCapability { ListChanged = true },
        Sampling = new SamplingCapability(),
        Elicitation = new ElicitationCapability
        {
            Form = new FormElicitationCapability(),
            Url = new UrlElicitationCapability()
        }
    }
};
```

**Auto-declared:** when you configure a `SamplingHandler` / `RootsHandler` / `ElicitationHandler` on the client, the corresponding capability is added automatically. Manual config is only needed for fine-grained sub-flags (e.g. `Form` vs `Url` for elicitation).

## Server capabilities — `ServerCapabilities`

| Capability | Type | Meaning |
| --- | --- | --- |
| `Tools` | `ToolsCapability` | Callable tools |
| `Prompts` | `PromptsCapability` | Prompt templates |
| `Resources` | `ResourcesCapability` | Readable resources (`Subscribe`, `ListChanged` sub-flags) |
| `Logging` | `LoggingCapability` | Server can `notifications/message` |
| `Completions` | `CompletionsCapability` | Argument auto-complete |
| `Experimental` | `IDictionary<string, object>` | Vendor extensions |

Server capabilities are **inferred** from what you register: `WithTools<T>()` → tools capability; `WithPrompts<T>()` → prompts; etc.

## Capability checking — client checks server

```csharp
await using var client = await McpClient.CreateAsync(transport);

if (client.ServerCapabilities.Tools is not null)
    var tools = await client.ListToolsAsync();

if (client.ServerCapabilities.Resources is { Subscribe: true })
    await client.SubscribeToResourceAsync("config://app/settings");

if (client.ServerCapabilities.Prompts is { ListChanged: true })
    mcpClient.RegisterNotificationHandler(NotificationMethods.PromptListChangedNotification, ...);

if (client.ServerCapabilities.Logging is not null)
    await client.SetLoggingLevelAsync(LoggingLevel.Info);

if (client.ServerCapabilities.Completions is not null)
    await client.CompleteAsync(new PromptReference { Name = "p" }, "lang", "py");
```

## Server checks client

```csharp
[McpServerTool]
public async Task<string> NeedsSampling(McpServer server, CancellationToken ct)
{
    if (server.ClientCapabilities?.Sampling is null)
        throw new McpException("Client does not support sampling");
    // ...
}
```

Calling a capability-required method on a peer that didn't advertise it throws `InvalidOperationException`.

## Protocol version negotiation

Auto-handled by the SDK. SDK 1.4.1 defaults to the latest stable protocol (`2025-11-25`) unless you explicitly pin via `McpClientOptions.ProtocolVersion`. Supported revisions in 1.4.x: `2024-11-05`, `2025-03-26`, `2025-06-18`, `2025-11-25`. There is no draft revision to opt into — `DRAFT-2026-v1` / MRTR is not shipped in 1.4.x (see `mrtr.md`).

After `initialize`:

```csharp
string? clientView = client.NegotiatedProtocolVersion;
string? serverView = server.NegotiatedProtocolVersion;  // inside a tool / handler
```

Version mismatch → init fails with error. Servers can branch on negotiated version when handling protocol-version-specific features.

`McpClientOptions.InitializeMeta` is gone in 1.4.0. Do not copy older samples that set it.
