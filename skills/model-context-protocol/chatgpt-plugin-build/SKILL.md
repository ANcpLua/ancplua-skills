---
name: chatgpt-plugin-build
description: Build ChatGPT and Codex plugins backed by an MCP server. Use when planning a plugin's use cases and tools, adding plugin extensions (sidebar app, panel, file viewer, settings, mentions, forms), MCP Events subscriptions, website annotations, bundled skills or OAuth sign-in, testing in developer mode, or packaging (plugin.json, mcp.json), submitting and updating a plugin.
---

# ChatGPT plugin build

OpenAI's pages are the contract: fetch the one page a step needs from [sources](references/sources.md) and cite it.

## Steps

1. **Inventory** the requests a person would make of the plugin without reading its docs, direct and indirect. One row per goal, with the fields and rules in [planning](references/planning.md); extend an existing inventory. Done when every row says support, defer or exclude, and every exclusion carries its reason.
2. **Contract** each tool the supported rows need, with the fields and annotations in [planning](references/planning.md). Done when every supported row reaches a useful result through named tools, and every tool serves a row.
3. **Shape** each supported row with the smallest part that completes it: a skill for instructions, an MCP tool for live data or controlled actions, UI only where people inspect, compare, edit, confirm or navigate. Done when every row names its part.
4. **Build** the branch the task needs. Read its reference before the first edit.

   | Need | Read | Done when |
   | --- | --- | --- |
   | Sidebar app, panel, file viewer, settings, display modes, deep links, model context, mentions, forms | [extensions](references/extensions.md) | `tools/list` shows the metadata; each entry point opens with its arguments (`{}`, or `FileInput` for a file) and renders from its first tool result |
   | ChatGPT acts on updates from the server | [events](references/events.md) | one event is listed, subscribed with a verified callback, delivered signed, refreshed and unsubscribed |
   | Feedback on a website in ChatGPT's built-in browser | [annotations](references/annotations.md) | targets, metadata and control values reach ChatGPT; the site works unchanged without the API |
   | A skill inside the plugin | Build skills, in [sources](references/sources.md) | the skill activates for its requests and completes them with the plugin's tools |
   | Sign-in for the MCP server | Authentication, in [sources](references/sources.md) | OAuth completes; a token with the wrong audience or scope is rejected |
   | Installable package, listing, review | [packaging](references/packaging.md) | it installs from a local marketplace and carries every review field and test case |

5. **Test in ChatGPT** through a developer-mode connection. Refresh the connection after every change to tools, metadata, authentication or UI resources, then run the inventory as the evaluation set: direct, indirect, follow-up, write-action and out-of-scope requests. Done when every row has a recorded tool choice, arguments, result, errors and confirmation.
