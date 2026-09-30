# Planning

Condensed from OpenAI's plan and concept pages, linked in [sources](sources.md).

## Use-case inventory

Gather expected requests from tasks people already complete in the product, from interviews, support requests, searches and feature requests, from the words people use for the product and its data, from workarounds that copy data between tools, and from the plugin's own name, listing, screenshots and starter prompts. Capture what people will expect first; compare it with what the API supports afterwards.

| Field | Question |
| --- | --- |
| User goal | What is the person trying to accomplish? |
| Example requests | How might they ask, directly and indirectly? |
| Expected result | What makes the interaction successful? |
| Required context | Which information, account access or prior state is needed? |
| Plugin capability | Can a skill handle it, or does it need an MCP tool? |
| Safety boundary | Could it expose data, change state, spend money or affect another person? |
| Support decision | Support in the first version, defer, or exclude on purpose? |

Group requests that share a goal: "list my open tasks", "what do I need to do today" and "show overdue work" are one task-review row with different filters.

Coverage check, per supported row:

1. A complete path leads from the request to a useful result.
2. Missing skills, tools, data, permissions and error states are named.
3. Every tool completes a recognisable user goal.
4. Write actions carry authorization and confirmation.
5. The plugin can say what it cannot do and offer a next step.

When only a slice of an expected workflow is supported, add the missing coverage or narrow the plugin's positioning.

Reasons that justify an exclusion: unacceptable safety or privacy risk; the product or API cannot do it reliably; it needs permissions the plugin cannot verify; the result would mislead without information the plugin cannot reach; it is out of scope for the first release and the listing says so. Recorded exclusions feed skill boundaries, tool descriptions, refusal behaviour, test cases and listing copy.

## Tool contracts

Map a use case to tools: write the outcome, list the information it needs, identify the reads, writes and external actions, group what forms one coherent action, and split where permissions, safety risk or confirmation differ. Keep reads and writes in separate tools. Check the plan against the inventory: every tool serves a use case, reads exist before the writes that need them, unsupported requests get a clear limitation instead of an unsafe approximation, and no two descriptions overlap.

| Field | Define |
| --- | --- |
| Name | A stable, action-oriented identifier |
| Title | A concise human-readable action |
| Description | The user goal and the conditions that should trigger the tool |
| Input schema | Required and optional parameters, types, allowed values, limits |
| Output schema | Structured fields the model can inspect and reuse |
| Authorization | The account, role or resource access the server verifies |
| Side effects | Data or external state the tool can change |
| Failure behaviour | Errors the model can explain or recover from |

A description states what the tool does, when to use it, how it differs from similar tools and its limits, in the words of user intent. Inputs are explicit, so correctness never rests on a guessed identifier or account scope. Results return stable identifiers and enough structure for follow-up calls, and leave out secrets, tokens, internal diagnostics and unneeded personal data.

Annotations follow behaviour: `readOnlyHint` is true only when the tool cannot change state; `destructiveHint` is true when an outcome is irreversible or hard to reverse; `openWorldHint` is true when the tool reaches the public internet or open-ended external entities, read-only tools such as web search included; a tool limited to a bounded private account or workspace is false even when that service is hosted elsewhere. Authorization, input validation and confirmation stay on the server whatever the annotations say.

## Shape

| Shape | Choose it when |
| --- | --- |
| Skills only | Instructions and the tools the model already has complete the workflow |
| MCP server only | The plugin needs MCP tools and no extra workflow instructions |
| Skills and MCP server | Skills guide the model through workflows that use the server's tools |
| MCP server with UI | Visual interaction materially improves part of an MCP-backed workflow |

A skill carries the workflow: when to call tools, in which order, what to do with incomplete results, what the final output contains. The server carries data, authentication, authorization and actions. Tools stay useful without the UI, so headless workflows complete.
