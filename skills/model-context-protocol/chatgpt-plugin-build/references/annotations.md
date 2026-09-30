# Website annotations

The Browser Annotation API lets a website shape how people annotate it in the built-in browser of the ChatGPT desktop app: what is selectable, which context travels with a selection, and which controls preview a change. Annotations already work on any site without code; this is the customisation layer. The page in [sources](sources.md) holds every option and limit. Checked on 2026-09-30.

## Where it runs

- In the desktop app's built-in browser, from the DevDay 2026 release on, as `document.oai.annotation`.
- On secure, top-level pages: HTTPS or localhost. An iframe gets neither text selection nor surfaces.
- Outside ChatGPT Enterprise and Edu workspaces, where the API isn't currently available.
- Feature-detect each method. Methods return synchronously and need no readiness event.

## Pick the integration

| Goal | Integration |
| --- | --- |
| Select a card or group as one object | `oai-annotation-container` on the region, `oai-annotatable="Name"` on each object |
| Select a phrase or sentence | `oai-annotation-container-text` on the region |
| Send context with a selection | `oai-annotation-metadata='{"key":"value"}'` on the target |
| Open an annotation from your own button | `document.oai.annotation.request(target, { initialComment, mode, enterAnnotationMode, metadata })` |
| Ask for feedback on an exact passage | `request(range, ...)` with a DOM `Range` |
| Open the editor in advanced mode | `<meta name="oai-annotation-editor-default-mode" content="advanced" />` |
| Preview properties or collect choices | `registerControls({ targets, controlsHeading, controlsMode, controls })` |
| Select objects drawn in a canvas | `registerSurface({ element, hitTest, renderSelection })` |
| Turn Annotation mode on or off | `toggle()` and `isActive()`, with the `oaiannotationmodechange` event |

## Rules that bite

- `request()` returns `{ accepted }`; read `accepted`, because the object itself is always truthy. A site-initiated request may need the user's permission.
- Metadata: up to six properties of string, finite number, boolean or `null`; keys up to 64 characters that start with an ASCII letter; strings up to 256 characters; 2,048 bytes serialized.
- `initialComment` holds up to 240 UTF-16 code units, a text range up to 20,000.
- Controls: types `range`, `select`, `toggle` and `color`, up to 12 per registration. Handle `oaiannotationcontrolchange`, whose detail carries `callback`, `value` and an `action` of `preview`, `preview-original` or `reset`; apply the supplied value for each, reversibly. `dispose()` removes the registration and leaves preview changes in place, so cleanup restores the original rendering itself.
- A surface's host is a connected HTML element outside shadow DOM. `hitTest` may return a promise; call `invalidate()` after objects move or the zoom changes.
- On a hosted site registered controls appear by themselves. The manual Adjust, collapse and Option-click controls exist only in Codex and on localhost.
- When `oai-annotation-container` and `oai-annotation-container-text` sit on one element, text selection wins over element picking.

## Test

Run the page's "Test your integration" list, ending with the site opened in a browser without the API to confirm ordinary interactions still work.

To let ChatGPT act on the site as well, see site tools (WebMCP) in [sources](sources.md).
