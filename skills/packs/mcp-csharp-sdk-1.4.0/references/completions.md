# Completions

Server-provided auto-complete for prompt arguments and resource template parameters. Improves client UX as the user types.

## Two reference types

- `PromptReference { Name = "..." }` → completes a prompt's argument value
- `ResourceTemplateReference { Uri = "..." }` → completes a URI template's parameter value

## Two ways to provide completions

### A. `[AllowedValues]` — zero-config

For `string` parameters with a known fixed set, the SDK auto-emits matching completions. No handler needed:

```csharp
[McpServerPrompt]
public static ChatMessage CodeReview(
    [AllowedValues("csharp", "python", "javascript", "typescript", "go", "rust")]
    string language,
    string code) => ...;

[McpServerResource("config://settings/{section}")]
public static string ReadConfig(
    [AllowedValues("general", "network", "security", "logging")] string section) => ...;
```

Client sends `completion/complete` with partial value → SDK filters by prefix → returns matches.

### B. `WithCompleteHandler` — dynamic

```csharp
builder.Services.AddMcpServer()
    .WithPrompts<MyPrompts>()
    .WithResources<MyResources>()
    .WithCompleteHandler(async (ctx, ct) =>
    {
        var arg = ctx.Params!.Argument;

        if (ctx.Params.Ref is PromptReference)
        {
            var pool = arg.Name switch
            {
                "language" => new[] { "csharp", "python", "javascript" },
                _ => Array.Empty<string>()
            };
            var hits = pool.Where(s => s.StartsWith(arg.Value, StringComparison.OrdinalIgnoreCase)).ToList();
            return new CompleteResult
            {
                Completion = new Completion { Values = hits, Total = hits.Count, HasMore = false }
            };
        }

        if (ctx.Params.Ref is ResourceTemplateReference)
        {
            // dynamic completion from filesystem/DB/etc
        }
        return new CompleteResult();
    });
```

Combining both works: handler's results return first, then `[AllowedValues]` matches.

## Client

```csharp
var result = await client.CompleteAsync(
    new PromptReference { Name = "code_review" },
    argumentName: "language",
    argumentValue: "type");
// result.Completion.Values: ["typescript"]

if (result.Completion.HasMore == true)
    Console.WriteLine($"+ more ({result.Completion.Total} total)");
```

Same shape for `ResourceTemplateReference { Uri = "..." }`.

## Capability check

```csharp
if (client.ServerCapabilities?.Completions is null) { /* not supported */ }
```
