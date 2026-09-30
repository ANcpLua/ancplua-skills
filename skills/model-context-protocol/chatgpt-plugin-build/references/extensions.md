# Plugin extensions

Extensions are metadata, capabilities, tools and a few host methods on top of MCP and MCP Apps. The specification in [sources](sources.md) holds every schema; this page holds the declaration sites and the rules that break builds. Checked against the specification and docs on 2026-09-30.

## Entry points

Declared in `_meta["openai/ui"].entrypoints` of a tool that already carries `_meta.ui.resourceUri`. Up to three per MCP App (global, thread, file). The SDK schema also accepts a `settings` entry point with `searchTerms` and a `quickAction` on `global`; the specification describes neither.

```json
{
  "ui": { "resourceUri": "ui://app/view.html" },
  "openai/ui": { "entrypoints": [{ "type": "global" }, { "type": "thread" }] }
}
```

| Type | Opens | Rule |
| --- | --- | --- |
| `global` | From the sidebar, fullscreen | The tool accepts `{}` as its arguments |
| `thread` | As a tab beside the conversation, one instance per thread | The tool receives `{}`; give it a title that differs from the plugin name (SHOULD) |
| `file` | In place of the default viewer for matching files | `extensions` takes the dotted form (`".stl"`); the tool receives `FileInput` `{ file: { name, resourceUri } }`, where `resourceUri` is opaque and ChatGPT handles its `resources/*` calls |

- An entry point ignores `_meta.ui.visibility`.
- The app renders from the initial tool result; a second call for the first paint is waste.
- Title comes from the tool's `title`, then `annotations.title`, then `name`.
- Icon comes from the tool's `icons`, then the local server icon (`_meta["io.modelcontextprotocol/serverInfo"].icons` in `server/discover`, or `serverInfo.icons` in `initialize` without `server/discover`) or, for a hosted app, the logo registered with OpenAI, then a generic fallback. Use a monochrome SVG on `currentColor`, 20x20 viewport, transparent background.
- Every entry point runs in `fullscreen`. ChatGPT supports `inline` and `fullscreen`; declare `availableDisplayModes` and `preferredDisplayMode` under `_meta["openai/ui"]` of the UI resource.
- The docs page shows `extensions: ["stl"]` without the dot; the specification requires the dot. Follow the specification.

## Deep links

A deep link opens a page inside a global entry point:

```text
https://chatgpt.com/plugins/<plugin-id>/app/<tool-name>?path=<encoded-app-relative-url>
{scheme}://plugins/{pluginId}@{marketplace}/app/{toolName}?path={encodedAppRelativePath}
```

`scheme` is `codex` on desktop and `chatgpt` on mobile. Omit `@{marketplace}` for a plugin published directly to ChatGPT, and percent-encode `pluginId` and `toolName`. The decoded path begins with `/` and has no fragment; a missing `path` means `/`. The app reads it from `hostContext["openai/deepLink"].url` at initialization and on `ui/notifications/host-context-changed`.

## Settings

Advertise `capabilities.extensions["openai/settings"] = { readTool, updateTool }` in `server/discover` on protocol `2026-07-28` or newer, or in `initialize` on `2025-11-25` and earlier, under `capabilities.extensions` or the legacy `capabilities.experimental`. The read tool accepts `{}`, is read-only, declares an `outputSchema` for `SettingsReadResult` and returns a value for every schema property. The server persists the settings.

## Model context and messages

The app learns what the host supports from `hostCapabilities` in the `ui/initialize` result: `experimental["openai/modelContext"]` with `updateModelContext`, and `experimental["openai/message"]` with `message`. `ui/update-model-context` is idempotent: each call replaces what the same app instance supplied before.

## Composer mentions

A mention search tool carries `_meta["openai/extensions"]["mentions/search"] = {}` and `"app"` in `_meta.ui.visibility`. It takes the typeahead query and returns items, which may be resource links.

## Forms

Pass the schema as `requestedSchema`; each option uses `const` and `title`, with an optional `x-openai-thumbnail`. A server registered with OpenAI needs protocol `2026-07-28` with multi-round-trip requests; only a direct connection may use the legacy `openai/elicitation/create` request.

## Platform support at launch

| Extension | Desktop | Web | iOS | Android |
| --- | --- | --- | --- | --- |
| Global and thread entry points, settings, display modes, model context, messages | yes | yes | yes | yes |
| Deep links | yes | yes | yes | no |
| Forms | yes | yes | no | no |
| File entry point, file opening, composer mentions | yes | no | no | no |
| Plugin onboarding | yes | yes | yes | yes |
| File resources | yes | no | no | no |

Web means the ChatGPT Work browser; classic ChatGPT is excluded. On iOS and Android, messages support only `{ target: "active", send: true }`; iOS takes no resource links in messages and no model-context thumbnails.

Extensions on the web reach ChatGPT Free and Go later than the other plans.

## SDK

`@openai/mcp-extensions` 0.1.0 declares peers `@modelcontextprotocol/sdk ^1.29.0` and the optional `@modelcontextprotocol/ext-apps ^1.7.5`; `ext-apps` 2.x falls outside that range. On the v2 package family (`@modelcontextprotocol/server` 2.x), write the metadata and capabilities by hand from the specification, and check the installed version before relying on either statement.

When the repository pins its own tool list in a snapshot test, regenerate that snapshot with each metadata change.
