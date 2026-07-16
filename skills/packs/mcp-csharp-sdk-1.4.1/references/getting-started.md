# Getting Started

Quick path: pick the right NuGet, write a minimal server / client, run.

## NuGet packages

| Package | Use when |
| --- | --- |
| **ModelContextProtocol.Core** | Only the client or low-level server APIs needed. Minimum deps. |
| **ModelContextProtocol** | Stdio server, or a client. Includes hosting, DI, attribute-based tool/prompt/resource discovery. References Core. **Default choice for most projects.** |
| **ModelContextProtocol.AspNetCore** | HTTP-based server hosted in ASP.NET Core. References ModelContextProtocol — you get everything plus HTTP transport. |

## Minimal stdio server

```bash
dotnet new console
dotnet add package ModelContextProtocol
dotnet add package Microsoft.Extensions.Hosting
```

```csharp
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using ModelContextProtocol.Server;
using System.ComponentModel;

var builder = Host.CreateApplicationBuilder(args);
builder.Logging.AddConsole(o => o.LogToStandardErrorThreshold = LogLevel.Trace);  // stdio: stderr only
builder.Services.AddMcpServer()
    .WithStdioServerTransport()
    .WithToolsFromAssembly();
await builder.Build().RunAsync();

[McpServerToolType]
public static class EchoTool
{
    [McpServerTool, Description("Echoes the message back")]
    public static string Echo(string message) => $"hello {message}";
}
```

`WithToolsFromAssembly()` finds every `[McpServerToolType]` class and registers every `[McpServerTool]` method. Same shape: `WithPromptsFromAssembly()`, `WithResourcesFromAssembly()`.

## Minimal HTTP server

```bash
dotnet new web
dotnet add package ModelContextProtocol.AspNetCore
```

```csharp
using ModelContextProtocol.Server;
using System.ComponentModel;

var builder = WebApplication.CreateBuilder(args);
builder.Services.AddMcpServer()
    .WithHttpTransport(o => o.Stateless = true)   // recommended unless you need sampling/elicitation/roots
    .WithToolsFromAssembly();
var app = builder.Build();
app.MapMcp();
app.Run("http://localhost:3001");

[McpServerToolType]
public static class EchoTool
{
    [McpServerTool, Description("Echoes the message")]
    public static string Echo(string message) => $"hello {message}";
}
```

### Host validation reminder

Kestrel doesn't validate `Host` headers by default. For local servers: limit `AllowedHosts` to loopback. For production: configure exact public host names at the proxy. Protects against DNS rebinding.

### CORS

Only enable if you intentionally want browser cross-origin access. CORS is not a substitute for host validation. When you enable it, use the most restrictive policy possible. See ASP.NET Core CORS docs.

## Minimal client

```bash
dotnet new console
dotnet add package ModelContextProtocol
```

```csharp
using ModelContextProtocol.Client;
using ModelContextProtocol.Protocol;

var transport = new StdioClientTransport(new StdioClientTransportOptions
{
    Name = "Everything",
    Command = "npx",
    Arguments = ["-y", "@modelcontextprotocol/server-everything"]
});

var client = await McpClient.CreateAsync(transport);

foreach (var tool in await client.ListToolsAsync())
    Console.WriteLine($"{tool.Name} — {tool.Description}");

var result = await client.CallToolAsync(
    "echo",
    new Dictionary<string, object?> { ["message"] = "Hello MCP!" },
    cancellationToken: CancellationToken.None);

Console.WriteLine(result.Content.OfType<TextContentBlock>().First().Text);
```

## Hand tools to an `IChatClient`

`McpClientTool` inherits `AIFunction`, so list output goes directly to MEAI:

```csharp
IList<McpClientTool> tools = await client.ListToolsAsync();
IChatClient chat = /* OllamaChatClient / OpenAIChatClient / etc */;
var response = await chat.GetResponseAsync("your prompt", new() { Tools = [.. tools] });
```

## Next steps

Read the topic-specific references — `tools.md`, `resources.md`, `prompts.md`, `transports.md`. Samples live at: https://github.com/modelcontextprotocol/csharp-sdk/tree/main/samples
