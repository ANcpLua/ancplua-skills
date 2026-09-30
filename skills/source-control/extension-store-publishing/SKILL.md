---
name: extension-store-publishing
description: >-
  Enable, wire up, and operate automated browser-extension publishing to all three stores — Microsoft Edge
  Add-ons (Partner Center Publish API, ApiKey auth), Chrome Web Store (API v2, Google OAuth refresh token),
  and Firefox Add-ons / AMO (API v5, HS256 JWT). Use whenever the task touches publishing or updating a
  browser extension on any store, a publish:edge / publish:chrome / publish:firefox script, the env vars
  EDGE_PRODUCT_ID / EDGE_API_KEY / EDGE_CLIENT_ID / CWS_CLIENT_ID / CWS_CLIENT_SECRET / CWS_REFRESH_TOKEN /
  CWS_PUBLISHER_ID / CWS_ITEM_ID / AMO_JWT_ISSUER / AMO_JWT_SECRET, enabling a store publish API, a failing upload, "submission
  in progress" / "pending review" errors, or automating extension releases — and ESPECIALLY when you are
  tempted to conclude publishing is blocked because API credentials are missing. Missing credentials are a
  minutes-long console fix, never a blocker.
license: Apache-2.0
---

# Browser extension store publishing — Edge, Chrome, Firefox, end to end

Every fact here was verified **end-to-end on 2026-07-10** with a real extension (`savemedia` 0.0.5 → 0.0.6):
Edge Publish API enabled + credentials minted + update submitted; AMO JWT keys minted + 0.0.6 uploaded,
validated, and submitted with source attached; Chrome OAuth refresh-token flow verified against a live
pending-review item. Reference implementations: `savemedia/packages/extension/scripts/publish-{edge,chrome,firefox}.mjs`
(all dependency-free Node, global `fetch`).

## The rule that overrides your instinct

**"No store API credentials" is never a stopping point.** Each store hands them out in minutes:

| Store | Where | What you get | Auth on the wire |
|---|---|---|---|
| Edge | partner.microsoft.com → Edge program → Publish API → **Turn on API** | Client ID + API key (key shown once, ~14-month expiry) | `Authorization: ApiKey …` + `X-ClientID: …` |
| Chrome | Google Cloud project → enable Chrome Web Store API → OAuth client → one-time consent for a refresh token | client id/secret + refresh token + publisher id + item id | `Authorization: Bearer <access token from refresh grant>` (API v2) |
| Firefox | addons.mozilla.org/developers/addon/api/key/ (email-confirmation link, then keys appear) | JWT issuer (`user:…`) + JWT secret (shown once) | `Authorization: JWT <self-signed HS256, exp ≤ 5 min>` |

Store values in CI secrets and/or macOS keychain (`security add-generic-password -U -a "$USER" -s NAME -w '…'`);
commit only the env var names.

## Per-store API shape

### Edge (Partner Center Publish API v1.1 — the old Azure AD flow is retired)
- Root `https://api.addons.microsoftedge.microsoft.com`
- Upload: `POST /v1/products/{productId}/submissions/draft/package` (`Content-Type: application/zip`, raw bytes)
  → `202` + `Location: <operationId>`; poll `…/draft/package/operations/{id}` until `Succeeded`
- Publish: `POST /v1/products/{productId}/submissions` with `{"notes":"…"}` → `202`; poll `…/submissions/operations/{id}`
- Credential sanity check: GET an operations URL with a bogus GUID — **404 = auth OK** (401 = bad creds)

### Chrome (Web Store API v2 — v1.1 is deprecated, EOL 2026-10-15; do NOT write new v1.1 code)
- Token: `POST https://oauth2.googleapis.com/token` (client_id, client_secret, refresh_token, grant_type=refresh_token) — refresh-token auth works fine with v2; a service account is optional, not required
- **Refresh-token time bomb**: if the OAuth consent screen is in **Testing** publishing status (the default fast path), Google expires refresh tokens after **7 days** — publishes silently start failing with `invalid_grant`. Fix once: Audience page → **Publish app** (production; no verification needed since `chromewebstore` isn't a sensitive/restricted scope, consent just shows an "unverified app" interstitial only you will ever see), then re-run the consent flow to mint a fresh token — tokens minted while in Testing keep their 7-day fuse.
- Root `https://chromewebstore.googleapis.com`; paths need BOTH the publisher id (dashboard URL / Publisher → Settings) and the item id
- Upload: `POST /upload/v2/publishers/{publisherId}/items/{itemId}:upload` (zip bytes; manifest version must be bumped)
- Publish: `POST /v2/publishers/{publisherId}/items/{itemId}:publish` (publishes with existing visibility settings)
- Status: `GET /v2/publishers/{publisherId}/items/{itemId}:fetchStatus` → `publishedItemRevisionStatus.state`, `crxVersion`

### Firefox (AMO API v5)
- JWT: HS256, payload `{iss, jti: uuid, iat: now-5, exp: now+240}` — AMO rejects exp > 5 min
- Upload: `POST https://addons.mozilla.org/api/v5/addons/upload/` (multipart: `upload` = zip, `channel` = listed)
  → poll `GET /addons/upload/{uuid}/` until `processed`; require `valid`
- Create version: `POST /addons/addon/{addon-id}/versions/` with **JSON** `{"upload": uuid, "release_notes": {"en-US": "…"}}`
  — release_notes is a lang-code object; sending it as a multipart string fails with
  `You must provide an object of {lang-code:value}`
- Source zip (required for minified/bundled builds): separate multipart
  `PATCH /addons/addon/{addon-id}/versions/{versionId}/` with `source`
- `{addon-id}` = the gecko id from `browser_specific_settings.gecko.id` in the manifest
- Status: `GET /addons/addon/{addon-id}/versions/?filter=all_with_unlisted`

## Hard-won facts / failure modes (all observed)

- **First submission is always manual** on every store (listing, privacy, screenshots). The APIs only update
  existing listings; enable/wire the API after the first hand-submission.
- Edge allows only **one submission in flight per product**. "Can't publish extension as your extension
  submission is in progress" has two causes, same message: (a) right after a green upload, the publish DID get
  accepted and a retry raced it — check Partner Center; if the version shows **In review**, the release
  succeeded, don't resubmit; (b) a *previous* version is still in Microsoft's ~7-day review — the new package
  still uploads into the draft, only the publish is blocked; it goes through once the pending review clears
  (re-run the publish then, no re-upload needed).
- CI consequence of (b): in a multi-store release job, make the store steps independent
  (`if: ${{ !cancelled() }}` on each publish step in GitHub Actions) — otherwise Edge's expected
  one-in-flight rejection blocks Chrome/Firefox publishes that would have succeeded.
- Chrome: **"The item cannot be updated now because it is in pending review…"** means a version is already in
  review (check state via `:fetchStatus`) — expected state, not an error to fix.
- Edge API key and AMO JWT secret are displayed **only once**. If lost, regenerate/rotate — you cannot re-read
  them (AMO masks the secret on revisits; regenerating revokes the old issuer suffix and mints a new one).
- AMO keys only appear after clicking the **email confirmation link**; the key page before confirmation just
  offers to resend the email.
- Reviews: Edge up to ~7 business days; AMO listed-channel review is queued server-side; the previous version
  stays live everywhere until the new one is approved.
- Multiple extensions in one account: match repo/package name against the store dashboard and confirm the
  exact Product ID / item id / gecko id — don't guess from the first GUID you see.

## Release runbook (per store, local with keychain creds)

```bash
# Edge
export EDGE_PRODUCT_ID=$(security find-generic-password -a "$USER" -s EDGE_PRODUCT_ID -w)
export EDGE_API_KEY=$(security find-generic-password -a "$USER" -s EDGE_API_KEY -w)
export EDGE_CLIENT_ID=$(security find-generic-password -a "$USER" -s EDGE_CLIENT_ID -w)
node scripts/publish-edge.mjs release --notes "vX.Y.Z automated release"

# Chrome
export CWS_CLIENT_ID=… CWS_CLIENT_SECRET=… CWS_REFRESH_TOKEN=… CWS_PUBLISHER_ID=… CWS_ITEM_ID=…   # same keychain pattern
node scripts/publish-chrome.mjs release

# Firefox (attach source zip for bundled builds)
export AMO_JWT_ISSUER=… AMO_JWT_SECRET=…
node scripts/publish-firefox.mjs release --notes "vX.Y.Z automated release" --source savemedia-source-X.Y.Z.zip
node scripts/publish-firefox.mjs status   # expect the new version as "unreviewed"
```

All three scripts share the same shape: `update`/`upload` (push zip + poll validation), `publish`/`release`
(submit for review + poll), ~150 lines each, no dependencies.
