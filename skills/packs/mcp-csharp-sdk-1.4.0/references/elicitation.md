# Elicitation

Server-to-client request for **additional input from the user** mid-tool-execution. Two modes:

| Mode | Use for |
| --- | --- |
| **Form (in-band)** | Structured fields — strings, numbers, booleans, single-/multi-select enums. Client renders a form |
| **URL (out-of-band)** | OAuth flows, payment, sensitive credential entry. Client opens a URL in a browser |

> Direct form `ElicitAsync` requires stateful HTTP or stdio. Stateless-compatible form input uses MRTR; URL mode also has a stateless-compatible escape hatch via `UrlElicitationRequiredException`.

## Server — Form mode

```csharp
var result = await server.ElicitAsync(new ElicitRequestParams
{
    Message = "Configure your preferences",
    RequestedSchema = new ElicitRequestParams.RequestSchema
    {
        Properties = new Dictionary<string, ElicitRequestParams.PrimitiveSchemaDefinition>
        {
            ["name"] = new ElicitRequestParams.StringSchema { Description = "Display name", Default = "User" },
            ["maxResults"] = new ElicitRequestParams.NumberSchema { Description = "Max results", Default = 25 },
            ["notify"] = new ElicitRequestParams.BooleanSchema { Description = "Notifications", Default = true },
            ["theme"] = new ElicitRequestParams.UntitledSingleSelectEnumSchema
            {
                Description = "UI theme",
                Enum = ["light", "dark", "system"],
                Default = "system"
            },
            ["priority"] = new ElicitRequestParams.TitledSingleSelectEnumSchema
            {
                Description = "Priority",
                OneOf =
                [
                    new() { Const = "p0", Title = "Critical (P0)" },
                    new() { Const = "p1", Title = "High (P1)" }
                ],
                Default = "p1"
            },
            ["tags"] = new ElicitRequestParams.UntitledMultiSelectEnumSchema
            {
                Description = "Tags",
                Items = new() { Enum = ["bug", "feature", "docs"] },
                Default = ["bug"]
            }
        }
    }
}, ct);

// result.Action is "accept" | "decline" | "cancel" | "reject"
// result.Content is Dictionary<string, JsonElement>
```

### Enum schema variants

| Schema | Layout |
| --- | --- |
| `UntitledSingleSelectEnumSchema` | Values are the labels |
| `TitledSingleSelectEnumSchema` | Separate `Const` value + `Title` label (`oneOf` w/ const+title) |
| `UntitledMultiSelectEnumSchema` | Multi-select, no labels |
| `TitledMultiSelectEnumSchema` | Multi-select, labelled |
| `LegacyTitledEnumSchema` | Deprecated, `enumNames`-based |

## Server — URL mode

For OAuth / payment / credential entry. Browser-only interaction, no value returned through MCP:

```csharp
var elicitationId = Guid.NewGuid().ToString();
await server.ElicitAsync(new ElicitRequestParams
{
    Mode = "url",
    ElicitationId = elicitationId,
    Url = $"https://auth.example.com/oauth/authorize?state={elicitationId}",
    Message = "Authorise access by signing in via your browser."
}, ct);
```

## Server — stateless escape hatch: `UrlElicitationRequiredException`

JSON-RPC error code `-32042`. Tells the client: "complete these URL flows, then retry":

```csharp
[McpServerTool]
public async Task<string> AccessThirdParty(McpServer server, CancellationToken ct)
{
    if (!HasCredentials(currentUser))
    {
        throw new UrlElicitationRequiredException(
            "Authorisation required.",
            [ new ElicitRequestParams
              {
                  Mode = "url",
                  ElicitationId = Guid.NewGuid().ToString(),
                  Url = $"https://auth.example.com/connect?…",
                  Message = "Authorise access to Example Co."
              } ]);
    }
    return await DoWork();
}
```

Works in stateless mode because it's a *result* sent down the POST stream, not an in-flight server→client request. The client opens the URL, gets consent, and **retries the original call**. Optional `notifications/elicitation/complete` notification when the out-of-band step finishes.

## Server — MRTR form mode in 1.4.0

For stateless-compatible structured input, throw `InputRequiredException` instead of calling `ElicitAsync`:

```csharp
if (context.Params?.InputResponses?.TryGetValue("user_input", out var response) is true)
{
    var result = response.Deserialize(InputResponse.ElicitResultJsonTypeInfo);
    return result?.Content?["name"].ToString() ?? "";
}

if (!server.IsMrtrSupported)
    return "This tool requires MRTR support.";

throw new InputRequiredException(
    inputRequests: new Dictionary<string, InputRequest>
    {
        ["user_input"] = InputRequest.ForElicitation(new ElicitRequestParams
        {
            Message = "Configure your preferences",
            RequestedSchema = new()
            {
                Properties = new Dictionary<string, ElicitRequestParams.PrimitiveSchemaDefinition>
                {
                    ["name"] = new ElicitRequestParams.StringSchema { Description = "Display name" }
                }
            }
        })
    },
    requestState: "awaiting-user-input");
```

Direct `ElicitAsync` still works for stdio and current-protocol stateful HTTP. Under draft Streamable HTTP, prefer MRTR.

## Client — handler

```csharp
var options = new McpClientOptions
{
    Capabilities = new ClientCapabilities
    {
        Elicitation = new ElicitationCapability
        {
            Form = new FormElicitationCapability(),
            Url = new UrlElicitationCapability()
        }
    },
    Handlers = new McpClientHandlers
    {
        ElicitationHandler = async (request, ct) =>
        {
            if (request?.Mode == "url")
            {
                // present url + message, get consent, open browser, return Action="accept"
            }
            // form mode — iterate request.RequestedSchema.Properties, collect input
            return new ElicitResult { Action = "accept", Content = collected };
        }
    }
};
```

## Capability check on server

```csharp
if (server.ClientCapabilities?.Elicitation is null)
    throw new McpException("Client does not support elicitation");
```

## Three useful patterns

- **Third-party OAuth** — URL elicitation + `UrlElicitationRequiredException` for stateless
- **Payment confirmation** — URL mode to a secure trusted page, not through the MCP client
- **Workflow input** — Form mode when the tool needs structured user choice mid-flow
