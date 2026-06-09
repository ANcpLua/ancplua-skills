# Tools

Server-exposed callable functions. The primary mechanism for LLMs to take action through MCP.

## Definition mechanisms

| Mechanism | Use |
| --- | --- |
| `[McpServerToolType]` + `[McpServerTool]` | **Default** — attribute on methods of a class |
| `McpServerTool.Create(delegate / MethodInfo / AIFunction, McpServerToolCreateOptions?)` | Factory for dynamically-built tools |
| Derive from `McpServerTool` or `DelegatingMcpServerTool` | Custom tool classes |
| Custom `McpRequestHandler<TParams,TResult>` via `McpServerHandlers` | Low-level handler override |
| `McpRequestFilter<TParams,TResult>` | Cross-cutting wrap |

## Attribute-based

```csharp
[McpServerToolType]
public class MyTools
{
    [McpServerTool, Description("Echoes the input back")]
    public static string Echo([Description("The message to echo")] string message) => $"Echo: {message}";
}
```

Register:

```csharp
builder.Services.AddMcpServer()
    .WithHttpTransport(o => o.Stateless = true)
    .WithTools<MyTools>();
```

Or auto-discover: `.WithToolsFromAssembly()`.

## Auto-injected parameters (not in JSON schema)

| Type | Resolved from |
| --- | --- |
| `McpServer` | DI — current server instance |
| `IProgress<ProgressNotificationValue>` | SDK auto-bridges to `notifications/progress` |
| `ClaimsPrincipal?` | `JsonRpcMessage.Context.User` — see `identity.md` |
| Any DI service | Request-scoped service provider |
| `RequestContext<CallToolRequestParams>` | Current request envelope |
| `CancellationToken` | Linked to request / session — see `cancellation.md` |
| `ProgressToken?` | Caller-supplied token for `notifications/progress` |

These are excluded from the generated JSON schema; clients never see them.

## Return types — auto-mapped

| .NET return | Becomes |
| --- | --- |
| `string` | Single `TextContentBlock` |
| `ContentBlock` | That block directly |
| `IEnumerable<ContentBlock>` | Multiple blocks |
| `DataContent` (Microsoft.Extensions.AI) | Image / audio / embedded resource based on MIME |
| `McpTask` | Bypasses auto task-wrapping, returned as-is — see `tasks.md` |

### Content factories

```csharp
ImageContentBlock.FromBytes(pngBytes, "image/png");
AudioContentBlock.FromBytes(wavBytes, "audio/wav");
BlobResourceContents.FromBytes(bytes, "data://items/x", "application/octet-stream");
```

### Mixed content example

```csharp
[McpServerTool, Description("Returns text and an image")]
public static IEnumerable<ContentBlock> DescribeImage()
{
    return
    [
        new TextContentBlock { Text = "Here is the image:" },
        ImageContentBlock.FromBytes(GetImage(), "image/png"),
        new TextContentBlock { Text = "It shows a landscape." }
    ];
}
```

### Content annotations

Any block can carry `Annotations` — `Audience` (`[Role.Assistant]` to hide from user, `[Role.User]` to surface) and `Priority` (0.0-1.0). Used by clients to decide what to render.

## Structured output in 1.4.0

Set `UseStructuredContent = true` to advertise `Tool.OutputSchema` and populate `CallToolResult.StructuredContent`.

```csharp
public sealed record WeatherResult(string City, double TemperatureC);

[McpServerTool(UseStructuredContent = true)]
public static WeatherResult GetWeather(string city) =>
    new(city, 21.5);
```

If the method returns `CallToolResult` directly but still needs to advertise a typed output schema, set `OutputSchemaType`:

```csharp
[McpServerTool(UseStructuredContent = true, OutputSchemaType = typeof(WeatherResult))]
public static CallToolResult GetWeatherEnvelope(string city) =>
    new()
    {
        StructuredContent = new WeatherResult(city, 21.5)
    };
```

Factory-created tools use `McpServerToolCreateOptions.UseStructuredContent` and `OutputSchema`.

## `[McpServerTool]` behavioural attributes

Behavioural hints clients use for safety / retry / human-in-loop policy. Set them per tool:

```csharp
[McpServerTool(
    Name = "turn_left",
    Title = "Turn Left",
    ReadOnly = false,        // mutates external state
    Destructive = true,      // not trivially undoable
    Idempotent = false,      // each call accumulates
    OpenWorld = false,       // interacts only locally
    TaskSupport = ToolTaskSupport.Optional),
 Description("Turn the robot anticlockwise")]
public static Task<string> TurnLeftAsync([Description("Angle in degrees")] int angle) { ... }
```

`TaskSupport`: `Forbidden` (default sync) | `Optional` (default async) | `Required` — see `tasks.md`.

## Error handling

**Tool errors are NOT protocol errors.** Tool failure returns a normal `CallToolResult` with `IsError = true` and content describing the problem.

Automatic exception handling:
- `McpProtocolException` → re-thrown as JSON-RPC error response
- `OperationCanceledException` → re-thrown when the cancellation token fired
- `McpException` (non-protocol) → message included in `IsError = true` result text
- **Everything else** → generic "An error occurred invoking '<tool>'." (no detail leaked)

```csharp
[McpServerTool, Description("Divides two numbers")]
public static double Divide(double a, double b)
{
    if (b == 0)
        throw new ArgumentException("Cannot divide by zero");
    // → client sees "An error occurred invoking 'divide'." (generic)
    return a / b;
}

[McpServerTool]
public static string Process(string input)
{
    if (string.IsNullOrEmpty(input))
        throw new McpProtocolException("Missing required input", McpErrorCode.InvalidParams);
    // → JSON-RPC error code -32602, message "Missing required input"
    return $"Processed: {input}";
}
```

Client side:

```csharp
var result = await client.CallToolAsync("divide", new Dictionary<string, object?> { ["a"] = 10, ["b"] = 0 });
if (result.IsError == true)
    Console.WriteLine($"Tool error: {result.Content.OfType<TextContentBlock>().FirstOrDefault()?.Text}");
```

## Tool-list change notifications

Requires **stateful or stdio** (unsolicited).

```csharp
await server.SendNotificationAsync(
    NotificationMethods.ToolListChangedNotification,
    new ToolListChangedNotificationParams());
```

```csharp
mcpClient.RegisterNotificationHandler(
    NotificationMethods.ToolListChangedNotification,
    async (notification, ct) =>
    {
        var fresh = await mcpClient.ListToolsAsync(cancellationToken: ct);
    });
```

## HTTP parameter headers in 1.4.0

Use `[McpHeader]` when infrastructure needs to route on a tool argument without parsing the JSON-RPC body. The SDK adds `x-mcp-header` to the input schema; Streamable HTTP clients mirror the argument into `Mcp-Param-{Name}`.

```csharp
[McpServerTool]
public static string ExecuteSql(
    [McpHeader("Region")] string region,
    string query)
{
    return $"Routing {query} to {region}";
}
```

Only primitive `string`, numeric, and boolean parameters may use `[McpHeader]`. Header names must be ASCII visible characters excluding colon. In 1.4.0, standard MCP HTTP header validation is gated to `DRAFT-2026-v1`.

## JSON Schema generation

Auto-generated from method signature. Maps:

| .NET | JSON Schema |
| --- | --- |
| `string` | `string` |
| `int`, `long` | `integer` |
| `float`, `double` | `number` |
| `bool` | `boolean` |
| Complex types | `object` with `properties` |

`[Description]` on parameters → `description` field in schema. Default-valued parameters → `default` field. `[AllowedValues]` → completions (see `completions.md`).

## qyl.mcp implication

The canonical `WithTools<T>()` pattern fully covers what qyl's removed generators / `[QylSkill]` / `[QylCapability]` attributes used to do. No custom attributes needed:

- Skills enum-style grouping → encode in tool *class structure*: `MyAutofixTools`, `MyTriageTools` registered with separate `WithTools<T>()` calls gated by `if (skills.IsEnabled(...))`
- Tool manifest enumeration for embedded ChatClient loops → `IEnumerable<McpServerTool>` injected from DI gives the live registered set
- Authorisation → `[Authorize(Roles = "qyl:admin")]` + `AddAuthorizationFilters()` — see `identity.md`
