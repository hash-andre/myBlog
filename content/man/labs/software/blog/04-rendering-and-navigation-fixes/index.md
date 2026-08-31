---
title: "04 — Fixing favicons, mathematics, links, and navigation"
description: "Root-cause analysis for four visible rendering and publication problems"
date: 2026-08-23T18:00:00+02:00
show_in_posts: true
weight: 50
---

## Symptoms

Four problems were visible after the network import:

1. the favicon did not appear;
2. LaTeX expressions were displayed literally, including their `$` delimiters;
3. some external links appeared as long raw URLs with no descriptive label;
4. the posts section did not contain the new manual articles.

A fifth symptom appeared in the table of contents for “Hub, switch e ARP”: an
empty nested bullet. These issues looked unrelated, but each came from a
mismatch between content metadata, theme expectations, and generated output.

## Favicon: the file existed under the wrong contract

The project already had an SVG icon, but a theme does not discover arbitrary
asset names. Its head template requests specific resources under
`assets/icons/`, including:

```text
favicon.svg
favicon.ico
favicon-16x16.png
favicon-32x32.png
apple-touch-icon.png
android-chrome-192x192.png
android-chrome-512x512.png
```

The solution was to provide the complete expected set rather than rely on a
single differently named source. The SVG is the editable source; raster sizes
and the ICO cover browsers, pinned icons, and installed web-app contexts that do
not use the SVG.

### Favicon caching

Favicons are cached aggressively and can appear stale even after the correct
file is deployed. A project partial adds a fingerprinted SVG URL:

```text
layouts/partials/custom-head.html
```

```go-html-template
{{- $favicon := resources.Get "icons/favicon.svg" | minify | fingerprint -}}
<link rel="icon" type="image/svg+xml" href="{{ $favicon.RelPermalink }}">
```

`fingerprint` includes a content hash in the generated filename. When the SVG
changes, its URL changes, so the browser no longer treats it as the same cached
resource.

An initial attempt placed the override under `layouts/_partials/`, but Hugo
reported the template as unused. The theme's extension point requested the
legacy `partials/custom-head.html` lookup path, so the project file had to match
that contract. The unused-template warning was the evidence that corrected the
location.

## Mathematics: the theme was conditional

The theme already contained a KaTeX helper. The scripts were not missing; the
head template loaded them only when either the page or the site enabled math:

```go-html-template
{{- if or .Params.math .Site.Params.math }}
  {{ partial "helpers/katex.html" . }}
{{- end -}}
```

The imported pages contained `$...$` and `$$...$$` expressions but did not set
the parameter. The correct page-level fix was:

```yaml
math: true
```

This keeps KaTeX selective. Enabling it globally would hide the missing metadata
but load its CSS and JavaScript on pages that never render an expression.

The helper was also checked to confirm that its auto-render configuration
recognizes both delimiters used by the notes:

```js
delimiters: [
  { left: "$$", right: "$$", display: true },
  { left: "$", right: "$", display: false },
]
```

## Links: an URL is not a useful mention

Notion exports preserved some links as bare lines:

```text
https://www.youtube.com/watch?v=...
```

The browser could make them clickable, but the reader had no indication of why
the destination mattered. They were converted into descriptive Markdown:

```md
[Video: cablaggio e pinout Ethernet](https://www.youtube.com/watch?v=...)
```

This improves scanning, accessibility, and maintenance. A meaningful label can
remain stable even if the target URL gains tracking parameters or changes host.

The source check searches for both naked URLs and Markdown labels that are only
URLs:

```text
line starts with https://...
line starts with [https://...](...)
```
