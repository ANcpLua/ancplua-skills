# MCP Events

ChatGPT subscribes to updates from the server and acts on each one as the user instructed. The MCP Events page in [sources](sources.md) holds the full request and response examples. Checked on 2026-09-30.

## Preconditions

- Protocol `2026-07-28`, which OpenAI calls MCP 2.0.
- Subscription storage that survives restarts, and outbound HTTPS to callback URLs.
- Webhook delivery with callback verification. ChatGPT supports neither polling nor streaming, nor the draft's `gap` and `terminated` notifications.

## Declare

Add `"events": {}` to the capabilities in the `server/discover` result, and implement three methods on the same authenticated MCP endpoint as the tools:

| Method | Server behaviour |
| --- | --- |
| `events/list` | Describe the events and their filters |
| `events/subscribe` | Create or refresh a subscription |
| `events/unsubscribe` | Stop a subscription |

An event definition carries `name`, `description`, `delivery: ["webhook"]`, `inputSchema` for the subscription arguments and `payloadSchema` for the `data` of a delivered event. Keep names stable, expose filters such as a project or queue ID, apply them on the server before delivery, and list only the events the connected account may discover. A long catalogue pages with `nextCursor` and `cursor`.

`@modelcontextprotocol/server` and `/core` 2.0.0 through 2.2.0 ship no `events/*` methods: register the three with `setRequestHandler(method, schemas, handler)` and add the capability yourself (`ServerCapabilities` has no `events` key, so cast). Confirm against the installed version.

## Subscribe

ChatGPT sends `name`, `arguments`, `delivery: { mode: "webhook", url, secret }`, `cursor` and optionally `ttlMs`. Before accepting:

1. Authorize the user for this event and these arguments.
2. Validate name and arguments against the definition. Require a `whsec_` secret whose base64 value decodes to 24 to 64 bytes.
3. Verify the callback, as below.
4. Store the subscription with its owner, filters, callback URL, secret and expiration.

Derive the subscription ID deterministically from the authenticated principal, callback URL, event name and arguments, comparing arguments as canonical JSON, so a repeated request updates the existing subscription. Return `{ id, refreshBefore, cursor, truncated }`; `cursor` is `null` for an event type without replay.

## Verify the callback

Send a signed POST with a fresh, single-use, short-lived challenge before any application data:

```json
{ "type": "verification", "challenge": "a-single-use-random-value" }
```

Give it a unique `webhook-id`, sign it with the subscription's secret, require a `2xx` response and compare the echoed `challenge` in constant time. Cache a success per principal and callback URL for a bounded period. On failure return JSON-RPC error `-32015` (`CallbackEndpointError`) with a categorized `data.reason` such as `challenge_failed` or `timeout`.

Every callback request, verification included, goes to HTTPS only, to an address resolved and validated at connection time, with the original hostname kept for TLS. Private, local and other non-public addresses are blocked, and redirects are refused.

## Deliver

POST one event per request, at most 256 KiB (262,144 bytes):

```json
{
  "eventId": "evt_456",
  "name": "comment.created",
  "timestamp": "2026-10-01T12:05:00Z",
  "data": {},
  "cursor": null
}
```

`name` matches the subscribed event and `data` matches its `payloadSchema`. Application fields stay inside `data`, because a top-level `type` marks a protocol control message. For a large record send a summary and offer a read tool for the rest. User-authored text travels as data, free of instructions to the model.

| Header | Value |
| --- | --- |
| `Content-Type` | `application/json` |
| `webhook-id` | The body's `eventId` |
| `webhook-timestamp` | Signing time in Unix seconds |
| `webhook-signature` | The Standard Webhooks HMAC signature |
| `X-MCP-Subscription-Id` | The ID `events/subscribe` returned |

The signature covers the event ID, the timestamp and the exact body bytes: serialize once and send those bytes.

A `2xx` acknowledges receipt. Retry transient failures with exponential backoff and a bounded number of attempts, keeping the event ID and signing afresh each time. `410` and `413` end the retries; by Standard Webhooks, `410` also means disabling that endpoint. Events can arrive out of order, so make write tools idempotent.

## Keep, refresh, stop

- Keep subscription state for the lifetime granted, across restarts. Recheck the user's access during that lifetime and stop delivery when it is revoked.
- ChatGPT refreshes by calling `events/subscribe` again before `refreshBefore`, with the same identity and its last cursor. Update the subscription and return the new expiration.
- `ttlMs` omitted means the server default; a value caps the grant, unless the server enforces a longer minimum; `ttlMs: null` asks for no expiration, and only then may `refreshBefore` be `null`.
- A refresh with a replacement secret replaces the stored one; during a short rotation window sign with both keys, space-separated.
- For replayable events the returned cursor never skips an event still awaiting delivery; return `truncated: true` when the requested history is gone.
- `events/unsubscribe` identifies the subscription by event name, arguments and callback URL. Stop delivery, return `{}`, stay idempotent, and authorize against the connected account.

## Test

Test on ChatGPT web or mobile: event-triggered tasks don't run in the desktop app, Codex CLI or the IDE extension, depend on the plan, and in a managed workspace need the admin permission **Allow event-triggered scheduled tasks** ([scheduled tasks](https://learn.chatgpt.com/docs/automations.md)). That page names only Gmail, Slack and GitHub as triggers, so record whether a developer-mode connection's events start a task. Events that arrive close together may share one run; **Scheduled** shows pending events and **Run now**.

Follow the lifecycle list on the page's "Test in ChatGPT" section, then add: repeated subscription requests, expiry and refresh across a server restart, account disconnection, revoked access to a subscribed resource, invalid signatures, duplicate deliveries, and bursts with batching on and off. When the requested action changes data in the source app, check that the resulting events create no feedback loop.
