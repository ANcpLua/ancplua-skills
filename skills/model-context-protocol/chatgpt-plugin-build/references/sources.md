# Documentation routes

Fetch one page for the step at hand. Every page under `developers.openai.com/plugins` and `learn.chatgpt.com/docs` has a Markdown twin: append `.md` to its URL. For a topic missing here, read [the plugin index](https://developers.openai.com/plugins/llms.txt) and pick the matching page; leave `llms-full.txt` alone. When a page and the specification disagree, the specification decides; say which one you followed.

| Task | Page |
| --- | --- |
| Inventory use cases | [Brainstorm plugin use cases](https://developers.openai.com/plugins/plan/use-case.md) |
| Contract the tools | [Define tools](https://developers.openai.com/plugins/plan/tools.md) |
| Choose the shape | [Plugin architecture](https://developers.openai.com/plugins/concepts/plugins.md), [skills](https://developers.openai.com/plugins/concepts/skills.md), [MCP server](https://developers.openai.com/plugins/concepts/mcp-server.md) |
| Build the MCP server | [Build an MCP server](https://developers.openai.com/plugins/build/mcp-server.md) |
| Sign-in, client registration, token checks | [Authentication](https://developers.openai.com/plugins/build/auth.md) |
| UI for a tool | [Add UI to your MCP server](https://developers.openai.com/plugins/build/chatgpt-ui.md), [UI guidelines](https://developers.openai.com/plugins/concepts/ui-guidelines.md), [reference](https://developers.openai.com/plugins/reference.md) |
| Plugin extensions | [Plugin Extensions](https://developers.openai.com/plugins/build/extensions.md), then the [specification](https://github.com/openai/mcp-extensions/blob/main/docs/spec.md) |
| Extension SDKs and a worked example | [TypeScript](https://github.com/openai/mcp-extensions/blob/main/typescript/README.md), [Python](https://github.com/openai/mcp-extensions/blob/main/python/README.md), [Bits & Bolts](https://github.com/openai/mcp-extensions/tree/main/plugins/bits-and-bolts) |
| Forms on a registered server | [Multi-round-trip requests](https://modelcontextprotocol.io/specification/2026-07-28/basic/patterns/mrtr) |
| Event subscriptions | [MCP Events](https://developers.openai.com/plugins/build/mcp-events.md), the [draft design](https://github.com/modelcontextprotocol/experimental-ext-triggers-events/blob/main/docs/design-sketch-proposal.md), [Standard Webhooks for JavaScript](https://github.com/standard-webhooks/standard-webhooks/tree/main/libraries/javascript) |
| Website annotations | [Annotations Extensibility](https://learn.chatgpt.com/docs/annotations-extensibility.md) |
| Actions on a website | [Site tools (WebMCP)](https://learn.chatgpt.com/docs/webmcp.md) |
| Skills in the plugin | [Build skills](https://developers.openai.com/plugins/build/skills.md) |
| Package and local marketplaces | [Package your plugin](https://developers.openai.com/plugins/build/plugins.md) |
| Connect and test | [Connect and test your plugin](https://developers.openai.com/plugins/deploy/connect-chatgpt.md) |
| Submit | [Upload and submit your plugin](https://developers.openai.com/plugins/deploy/submission.md), [submission errors](https://developers.openai.com/plugins/deploy/submission-errors.md) |
| Review and updates | [Remote MCP server review requirements](https://developers.openai.com/plugins/deploy/app-review.md), [plugin guidelines](https://developers.openai.com/plugins/plugin-guidelines.md) |
| Discovery and safety | [Optimize metadata](https://developers.openai.com/plugins/guides/optimize-metadata.md), [security and privacy](https://developers.openai.com/plugins/guides/security-privacy.md) |
| A Claude Code plugin as the starting point | [Submit your Claude Code plugin to OpenAI](https://developers.openai.com/plugins/guides/submit-claude-plugin.md) |
| Something breaks | [Troubleshooting](https://developers.openai.com/plugins/deploy/troubleshooting.md) |
