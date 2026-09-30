# Sampling

Server-to-client LLM completion. The server delegates reasoning back to the client's LLM — typical use: summarisation, decision-making, generation from inside a tool.

> `SampleAsync` / `AsSamplingChatClient()` requires stateful HTTP or stdio. **1.4.x has no stateless-compatible sampling path** — MRTR is not shipped in 1.4.x (see `mrtr.md`).

## Flow

```
Server tool runs → calls server.SampleAsync(...) or server.AsSamplingChatClient().GetResponseAsync(...)
  → request travels back to client over the open MCP connection
  → client's SamplingHandler invokes its own LLM
  → result returns to server, tool continues
```

## Server side — two ways

### A. `AsSamplingChatClient()` — Microsoft.Extensions.AI adapter

Cleanest for typical use. Returns an `IChatClient` that routes through the connected client's LLM:

```csharp
[McpServerTool, Description("Summarises text via the caller's LLM")]
public static async Task<string> Summarize(McpServer server, string text, CancellationToken ct)
{
    ChatMessage[] msgs =
    [
        new(ChatRole.User, "Briefly summarise the following:"),
        new(ChatRole.User, text)
    ];
    var opts = new ChatOptions { MaxOutputTokens = 256, Temperature = 0.3f };
    return await server.AsSamplingChatClient().GetResponseAsync(msgs, opts, ct);
}
```

### B. `SampleAsync` — lower level

Direct `CreateMessageRequestParams` / `CreateMessageResult`:

```csharp
var result = await server.SampleAsync(new CreateMessageRequestParams
{
    Messages = [ new SamplingMessage { Role = Role.User, Content = [new TextContentBlock { Text = "What is 2+2?" }] } ],
    MaxTokens = 100
}, ct);
```

## Client side

Provide a `SamplingHandler`. With Microsoft.Extensions.AI:

```csharp
IChatClient chatClient = new OllamaChatClient(new Uri("http://localhost:11434"), "llama3");

var options = new McpClientOptions
{
    Handlers = new() { SamplingHandler = chatClient.CreateSamplingHandler() }
};
```

Custom handler with content filtering, model routing, redaction, etc.:

```csharp
SamplingHandler = async (request, progress, ct) =>
{
    var prompt = request?.Messages?.LastOrDefault()?.Content.OfType<TextContentBlock>().FirstOrDefault()?.Text ?? "";
    return new CreateMessageResult
    {
        Model = "my-model",
        Role = Role.Assistant,
        Content = [new TextContentBlock { Text = $"Response to: {prompt}" }]
    };
}
```

## Capability negotiation

Setting `SamplingHandler` on the client auto-advertises the `sampling` capability. Server should check:

```csharp
if (server.ClientCapabilities?.Sampling is null)
    throw new McpException("Client does not support sampling");
```

Calling `SampleAsync` on a client that doesn't advertise sampling, or from stateless HTTP, throws `InvalidOperationException`.

## No stateless sampling in 1.4.x

There is no MRTR / `InputRequiredException` path in any shipped 1.4.x package (`mrtr.md` has the verification). A tool that needs a client-side LLM call must run under a stateful HTTP session or stdio. If the deployment must stay stateless, restructure: do the LLM work server-side, or split the tool so the client performs the reasoning between calls.

## Important

- Latency: each `SampleAsync` is a network roundtrip *plus* an LLM inference on the client. Don't chain unguarded.
- Cost / consent: the client's LLM is paying — show prompts to the user where appropriate
- Stateless servers can't use `SampleAsync` at all in 1.4.x — there is no stateless-compatible sampling path
