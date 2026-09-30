# Packaging, listing and review

Checked against the packaging, submission and review pages in [sources](sources.md) on 2026-09-30.

## Package

A portable plugin keeps these at its root:

```text
plugin.json      required manifest
mcp.json         MCP servers the plugin brings
skills/<name>/SKILL.md
assets/          icons, logo, screenshots
hooks/hooks.json
.app.json        mapping to an MCP server registered with ChatGPT
```

`plugin.json` needs `$schema` (`https://agent-plugins.org/schemas/1.0.0/plugin.schema.json`) and `name`, lowercase letters, numbers and single hyphens, at most 64 characters; give it an explicit semantic `version` for submission. OpenAI-specific settings go under `extensions.com.openai`: `apps: "./.app.json"`, `hooks`, `interface`, `onboardingSkill`, `review`, `publication`. When that object exists it replaces a `.codex-plugin/plugin.json` overlay entirely; the two never merge. Paths inside it are relative to the plugin root and start with `./`. `.app.json` and hooks serve local and workspace installs only: a submission ZIP must not contain `apps`/`.app.json` or lifecycle hooks. Declare the server in `mcp.json` and connect it in the dashboard.

`mcp.json` names each server with its transport:

```json
{
  "$schema": "https://agent-plugins.org/schemas/1.0.0/mcp.schema.json",
  "mcpServers": { "docs": { "type": "streamable-http", "url": "https://example.com/mcp" } }
}
```

The `@plugin-creator` scaffold writes the Codex layout instead: `.codex-plugin/plugin.json` and `.mcp.json`. The portable `mcp.json` adds `$schema` and a transport `type` per server, so a rename alone produces an invalid file.

## Connect the MCP server

1. In ChatGPT open Settings, Security and login, and turn on Developer mode.
2. At `https://chatgpt.com/plugins` select the plus button and enter the public HTTPS URL with its `/mcp` path.
3. Copy the technical ID from the browser URL; it starts with `plugin_asdk_app`. `.app.json` maps the plugin to that ID.
4. Install from a local marketplace (`.agents/plugins/marketplace.json` in the repository, or the personal one under the home directory) restart the ChatGPT desktop app, install from the Plugins Directory, and test in a new chat.

## Listing fields the review requires

Under `extensions.com.openai.interface`:

| Field | Limit |
| --- | --- |
| `displayName` | 30 characters |
| `shortDescription` | 30 characters |
| `longDescription` | 4000 characters |
| `developerName` | 80 characters |
| `category` | A category title from the dashboard |
| `websiteURL`, `supportURL`, `privacyPolicyURL`, `termsOfServiceURL` | HTTPS; all four are required for a plugin with an MCP server |
| `logo` (`composerIcon` is required for Codex only) | Square, at least 48 by 48 pixels; PNG, JPEG, WebP or SVG up to 5 MiB |

## Before submitting

- **Identity.** Individual or business verification in the OpenAI Platform dashboard for the name shown in the directory. Submitting needs the `api.apps.write` permission.
- **Endpoint.** A publicly reachable HTTPS endpoint with Streamable HTTP, never a local or test endpoint. With UI, a content security policy that allows exactly the domains the component fetches from.
- **Domain.** The exact challenge token from the portal, served as plain text, token only, at `https://<host>/.well-known/openai-apps-challenge` on the MCP hostname or an eligible parent domain.
- **Reviewer access.** When sign-in is required, a dedicated test account with sample data, the login URL and instructions, usable without MFA, email or SMS codes, magic links or private-network access. Credentials stay out of the ZIP.
- **Test cases.** Exactly five positive cases (scenario, prompt, expected tools, expected result; run with the test account first) and three negative cases (prompt, why not to act, expected refusal or fallback). Plugin-level `review.test_cases` needs exactly one MCP server.
- **Walkthrough and notes.** `review.demo_recording_url` (required for MCP review) and `publication.release_notes`.

## After publication

OpenAI rescans the server's tools. A deleted tool disappears at the next scan; a new tool appears once it passes the automated checks; a changed tool keeps its previous definition live until the update passes. Keep the server compatible with the live definition while an update is held. Changes to listing text, assets, bundled skills or the packaged MCP configuration need a new ZIP and a new review. An MCP URL change goes through support; a new origin needs a new plugin.
