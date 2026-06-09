# Prompts

Server-defined reusable prompt templates. Clients list, parameterise, and compose into LLM conversations.

## Definition

`[McpServerPromptType]` class + `[McpServerPrompt]` methods. Same five definition mechanisms as Tools / Resources.

Return type:
- `ChatMessage` / `IEnumerable<ChatMessage>` — text + image content (Microsoft.Extensions.AI shape)
- `PromptMessage` / `IEnumerable<PromptMessage>` — when you need protocol-specific blocks like `EmbeddedResourceBlock`

Auto-injected parameter types: `McpServer`, `IProgress<ProgressNotificationValue>`, `ClaimsPrincipal`, any DI service.

## Simple prompt

```csharp
[McpServerPromptType]
public class MyPrompts
{
    [McpServerPrompt, Description("Greeting prompt")]
    public static ChatMessage Greeting() => new(ChatRole.User, "Hello! How can you help me today?");
}
```

## Prompt with arguments

```csharp
[McpServerPrompt, Description("Code review prompt")]
public static IEnumerable<ChatMessage> CodeReview(
    [Description("Programming language")] string language,
    [Description("Code to review")] string code) =>
[
    new(ChatRole.User, $"Please review the following {language} code:\n\n```{language}\n{code}\n```"),
    new(ChatRole.Assistant, "I'll review the code for correctness, style, and improvements.")
];
```

Register:

```csharp
builder.Services.AddMcpServer()
    .WithHttpTransport()
    .WithPrompts<MyPrompts>()
    .WithPrompts<CodePrompts>();
```

## Rich content

### Image — `ChatMessage` + `DataContent`

```csharp
[McpServerPrompt]
public static IEnumerable<ChatMessage> AnalyzeImage(string instructions)
{
    byte[] bytes = LoadImage();
    return [
        new ChatMessage(ChatRole.User, [
            new TextContent($"Analyse: {instructions}"),
            new DataContent(bytes, "image/png")
        ])
    ];
}
```

`DataContent` auto-maps:
- `image/*` → `ImageContentBlock`
- `audio/*` → `AudioContentBlock`
- Other → `EmbeddedResourceBlock` (binary)

### Embedded text resource — `PromptMessage`

`PromptMessage = Role + single Content block`. Use when you need explicit `EmbeddedResourceBlock` with text:

```csharp
[McpServerPrompt]
public static IEnumerable<PromptMessage> ReviewDocument(string documentId)
{
    var text = LoadDocument(documentId);
    return [
        new PromptMessage { Role = Role.User, Content = new TextContentBlock { Text = "Review:" } },
        new PromptMessage
        {
            Role = Role.User,
            Content = new EmbeddedResourceBlock
            {
                Resource = new TextResourceContents
                {
                    Uri = $"docs://documents/{documentId}",
                    MimeType = "text/plain",
                    Text = text
                }
            }
        }
    ];
}
```

For binary embedded resource: `BlobResourceContents.FromBytes(bytes, uri, mime)`.

## Client

```csharp
var prompts = await client.ListPromptsAsync();

foreach (var p in prompts)
{
    Console.WriteLine($"{p.Name}: {p.Description}");
    foreach (var arg in p.ProtocolPrompt.Arguments ?? [])
        Console.WriteLine($"  - {arg.Name}: {arg.Description} {(arg.Required == true ? "(required)" : "")}");
}

var result = await client.GetPromptAsync("code_review",
    new Dictionary<string, object?> { ["language"] = "csharp", ["code"] = "..." });

foreach (var msg in result.Messages)
    switch (msg.Content)
    {
        case TextContentBlock t: /* text */ break;
        case ImageContentBlock i: /* image */ break;
        case EmbeddedResourceBlock r: /* resource */ break;
    }
```

## List-change notifications

```csharp
await server.SendNotificationAsync(
    NotificationMethods.PromptListChangedNotification,
    new PromptListChangedNotificationParams());
```

Stateful-only (unsolicited).
