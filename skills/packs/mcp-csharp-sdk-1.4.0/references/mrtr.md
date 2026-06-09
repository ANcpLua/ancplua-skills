# MRTR

Multi Round-Trip Requests let a tool ask the client for input, receive the response on a retry, and finish the original tool call without requiring a persistent server-to-client JSON-RPC request.

In SDK 1.4.0 this is tied to the draft protocol revision `DRAFT-2026-v1`. Treat it as experimental draft surface, not a stable product contract.

## When to use it

Use MRTR when a tool needs one of these during execution:

- Elicitation: ask the user for structured input.
- Sampling: ask the client to run its LLM.
- Roots: ask the client for filesystem roots.
- Multi-step input: wizard-like tool calls with several rounds.
- Stateless-compatible interaction over Streamable HTTP.

For current non-draft stateful sessions and stdio, the legacy direct methods still work: `ElicitAsync`, `SampleAsync`, and `RequestRootsAsync`. For stateless HTTP or draft Streamable HTTP, prefer `InputRequiredException`.

## Client opt-in

MRTR activates when both peers negotiate `DRAFT-2026-v1`. The client opts in with `McpClientOptions.ProtocolVersion`; servers accept supported client versions automatically unless explicitly pinned.

```csharp
var clientOptions = new McpClientOptions
{
    ProtocolVersion = "DRAFT-2026-v1",
    Handlers = new McpClientHandlers
    {
        ElicitationHandler = HandleElicitationAsync,
        SamplingHandler = HandleSamplingAsync,
        RootsHandler = HandleRootsAsync,
    }
};
```

After initialization, check `client.NegotiatedProtocolVersion` or `server.NegotiatedProtocolVersion` if behavior depends on the draft.

## Server pattern

Check `server.IsMrtrSupported` before throwing. It is true when the negotiated protocol is `DRAFT-2026-v1`, or when the current stable protocol is running with a stateful session that can resolve requests through the compatibility path.

```csharp
[McpServerTool, Description("Asks the user a question through MRTR")]
public static string AskUser(
    McpServer server,
    RequestContext<CallToolRequestParams> context,
    [Description("Question to ask")] string question)
{
    if (context.Params?.InputResponses?.TryGetValue("answer", out var response) is true)
    {
        var result = response.Deserialize(InputResponse.ElicitResultJsonTypeInfo);
        return result?.Content?.FirstOrDefault().Value.ToString() ?? "";
    }

    if (!server.IsMrtrSupported)
    {
        return "This tool requires MRTR support: DRAFT-2026-v1 or a stateful current-protocol session.";
    }

    throw new InputRequiredException(
        inputRequests: new Dictionary<string, InputRequest>
        {
            ["answer"] = InputRequest.ForElicitation(new ElicitRequestParams
            {
                Message = question,
                RequestedSchema = new()
                {
                    Properties = new Dictionary<string, ElicitRequestParams.PrimitiveSchemaDefinition>
                    {
                        ["answer"] = new ElicitRequestParams.StringSchema
                        {
                            Description = "Answer"
                        }
                    }
                }
            })
        },
        requestState: "awaiting-answer");
}
```

## Retry data

On retry, data lands on the original request parameters:

- `RequestParams.InputResponses`: dictionary keyed by the `inputRequests` keys.
- `RequestParams.RequestState`: opaque string echoed back by the client.

Deserialize with the response type that matches the original input request:

- Elicitation: `response.Deserialize(InputResponse.ElicitResultJsonTypeInfo)`
- Sampling: `response.Deserialize(InputResponse.CreateMessageResultJsonTypeInfo)`
- Roots: `response.Deserialize(InputResponse.ListRootsResultJsonTypeInfo)`

There is no discriminator on the response payload; the tool must know which response type it requested.

## Multiple rounds

Throw `InputRequiredException` again on a retry to request another round. Use `requestState` to track the round, and keep it opaque to the client.

```csharp
if (context.Params?.RequestState == "need-age")
{
    // Process the second response and return a final tool result.
}

throw new InputRequiredException(
    inputRequests: new Dictionary<string, InputRequest>
    {
        ["age"] = InputRequest.ForElicitation(ageRequest)
    },
    requestState: "need-age");
```

The SDK limits current-protocol compatibility retries to 10 rounds. If a tool needs deeper interaction, require `DRAFT-2026-v1`.

## Compatibility matrix

| Protocol | Session mode | Behavior |
| --- | --- | --- |
| `DRAFT-2026-v1` | Stateless | Native MRTR. `InputRequiredResult` goes directly on the wire. |
| `DRAFT-2026-v1` | Stateful | Native MRTR today; draft direction is moving Streamable HTTP toward stateless-only. |
| Current stable protocol | Stateful / stdio | Compatibility resolver sends legacy client requests, then retries the handler with `InputResponses`. |
| Current stable protocol | Stateless | Not supported. Throwing `InputRequiredException` becomes an MCP error because there is no session and no draft MRTR wire support. |

## Direct methods vs MRTR

- `SampleAsync`, `ElicitAsync`, `RequestRootsAsync`: direct server-to-client JSON-RPC requests. Use for stdio or current-protocol stateful sessions when one-shot interaction is enough.
- `InputRequiredException`: tool returns an incomplete result. Use for stateless-compatible code and draft Streamable HTTP.
- `UrlElicitationRequiredException`: still useful for out-of-band OAuth/payment/browser flows. It is separate from MRTR.
