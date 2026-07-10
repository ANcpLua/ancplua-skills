---
name: edge-addons-publishing
description: >-
  Enable, wire up, and operate automated Microsoft Edge Add-ons store publishing via the Partner Center
  Publish API (ApiKey auth, REST v1.1). Use whenever the task touches publishing or updating a browser
  extension on the Edge Add-ons store, a publish:edge / publish-edge script, EDGE_PRODUCT_ID / EDGE_API_KEY /
  EDGE_CLIENT_ID env vars, enabling the Publish API in Partner Center, a failing package upload or "submission
  in progress" error, or automating extension releases — and ESPECIALLY when you are tempted to conclude
  publishing is blocked because API credentials are missing. Missing credentials are a 2-minute Partner
  Center fix, never a blocker.
license: Apache-2.0
---

# Edge Add-ons Publishing — Partner Center Publish API, end to end

Every fact here was verified **end-to-end on 2026-07-10**: the Publish API was enabled in a real Partner
Center account, real credentials were minted, and a real extension update (`savemedia` 0.0.5 → 0.0.6,
product `214e0682-…`) was uploaded, validated, and submitted for certification via the API. Documentation
of record: `learn.microsoft.com/microsoft-edge/extensions/update/api/using-addons-api`.

## The rule that overrides your instinct

**"No Edge API credentials" is never a stopping point.** If `EDGE_PRODUCT_ID`, `EDGE_API_KEY`, or
`EDGE_CLIENT_ID` are missing from env / keychain / repo secrets, it almost always means the Publish API was
simply never enabled — a one-button fix:

1. Open `https://partner.microsoft.com/en-us/dashboard/microsoftedge/publishapi` (signed into the publisher
   account).
2. Click **Turn on API**. This immediately mints a **Client ID** and one **API key** (shown once — copy it
   in that session; afterwards only *New API key* can replace it). Keys expire (~14 months); note the
   expiry shown in the table.
3. Get the **Product ID** (GUID) from the extension's overview page in Partner Center
   (Extension identity section, or the GUID in the dashboard URL).

Store all three where the publish flow needs them — GitHub Actions secrets for CI
(`gh secret set EDGE_API_KEY --body '…'` etc.) and/or macOS keychain for local runs
(`security add-generic-password -U -a "$USER" -s EDGE_API_KEY -w '…'`). Document only the env var names in
committed files, never values.

## API shape (v1.1, ApiKey auth — the old Azure AD ACS flow is retired)

- Root: `https://api.addons.microsoftedge.microsoft.com`
- Headers on every call: `Authorization: ApiKey <EDGE_API_KEY>` and `X-ClientID: <EDGE_CLIENT_ID>`
- Upload package (zip): `POST /v1/products/{productId}/submissions/draft/package`
  (`Content-Type: application/zip`, body = raw zip bytes) → `202` with `Location: <operationId>`
- Poll upload: `GET …/submissions/draft/package/operations/{operationId}` → `status` of
  `InProgress` / `Succeeded` / `Failed` (with `errors[]`)
- Publish draft: `POST /v1/products/{productId}/submissions` (JSON body `{"notes": "…"}`) → `202` +
  operation `Location`; poll `…/submissions/operations/{operationId}`
- Quick credential sanity check: GET any operations URL with a bogus GUID — **404 means auth passed**
  (bad credentials give 401).

## Hard-won facts / failure modes (all observed)

- **The API only UPDATES an existing listing.** The first-ever submission must be done by hand in Partner
  Center (Create new extension → upload zip → listing/privacy → submit). Enable the Publish API after that.
- **"Can't publish extension as your extension submission is in progress"** right after a successful upload
  usually means the publish DID get accepted and the second poll/retry raced it — check Partner Center: if
  the version shows **In review**, the release succeeded; don't resubmit.
- The API key is displayed **only in the session where it was created**. If it's lost, mint a new key
  (*New API key*) and rotate the stored secrets; you cannot re-read the old one.
- Certification of an update takes up to ~7 business days; the previous version stays live meanwhile.
- Ownership check when multiple extensions exist: match the repo/package name against the Partner Center
  overview list and confirm via the Product ID on the extension's own dashboard page — don't guess from the
  first GUID you see.

## Reference script pattern

A ~150-line Node script (no deps, global `fetch`) covers the whole flow with three commands:
`update` (upload zip + poll), `publish` (submit draft + poll), `release` (both). See
`savemedia/packages/extension/scripts/publish-edge.mjs` for the verified implementation; the essential
skeleton:

```js
const base = `https://api.addons.microsoftedge.microsoft.com/v1/products/${process.env.EDGE_PRODUCT_ID}`;
const headers = {
  Authorization: `ApiKey ${process.env.EDGE_API_KEY}`,
  "X-ClientID": process.env.EDGE_CLIENT_ID,
};
// upload
await fetch(`${base}/submissions/draft/package`, {
  method: "POST",
  headers: { ...headers, "Content-Type": "application/zip" },
  body: zipBytes,
}); // 202 → poll Location header until Succeeded
// publish
await fetch(`${base}/submissions`, {
  method: "POST",
  headers: { ...headers, "Content-Type": "application/json" },
  body: JSON.stringify({ notes }),
}); // 202 → poll; "submission in progress" after a green upload ⇒ verify in Partner Center first
```

Local run with keychain-stored credentials:

```bash
export EDGE_PRODUCT_ID=$(security find-generic-password -a "$USER" -s EDGE_PRODUCT_ID -w)
export EDGE_API_KEY=$(security find-generic-password -a "$USER" -s EDGE_API_KEY -w)
export EDGE_CLIENT_ID=$(security find-generic-password -a "$USER" -s EDGE_CLIENT_ID -w)
node scripts/publish-edge.mjs release --notes "vX.Y.Z automated release"
```
