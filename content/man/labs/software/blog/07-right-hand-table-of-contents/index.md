---
title: "07 — Moving the table of contents to the right"
description: "How manual documents gained a scroll-following outline without forking the theme"
date: 2026-08-30T10:30:00+02:00
show_in_posts: true
weight: 80
---

## The requested layout

The manual already generated a table of contents from each document's Markdown
headings. The problem was its position. It appeared as a full-width collapsible
block between the title and the article, while documentation sites normally
keep the outline beside the reading column.

The target behavior was:

```text
wide screen

breadcrumb + document title        Sommario
article body                        - section
article body                        - section
article body                          - subsection
```

The outline should follow the reader and remain in the same viewport position
while a long document scrolls. On a tablet or phone, however, forcing a second
column would make both the text and the links too narrow. The responsive
fallback therefore keeps the existing collapsible TOC in the normal document
flow.

## Where the original TOC came from

The project did not build the table of contents by parsing headings itself. The
theme already provides:

```text
themes/hugo-blog-awesome/layouts/_partials/toc.html
```

That partial resolves the global and page-level settings, then renders Hugo's
`.TableOfContents` inside a native `<details>` element:

```go-html-template
<details class="toc" open>
    <summary><b>Sommario</b></summary>
    {{ .TableOfContents }}
</details>
```

Hugo builds `.TableOfContents` from the IDs and hierarchy of Markdown headings.
The browser supplies the open/close behavior of `<details>`, so the menu does not
need custom JavaScript.

Before this change, `layouts/man/single.html` called that partial directly
between the document header and `.Content`. Because it was an ordinary block in
the article, it occupied the full reading-column width.

## Why the change belongs in `single.html`

The manual has two page types:

- `layouts/man/list.html` renders directories created by `_index.md`;
- `layouts/man/single.html` renders documents created by `index.md`.

A directory browser has children but no document outline. A regular document
has headings but no child listing. The TOC therefore belongs only to
`single.html`; adding it to `list.html` would mix two different navigation
models.

For clarity, the list wrapper now includes `man-directory-page`, while the
document wrapper uses `man-document-page`. These classes make the two roles
visible in the markup and allow document width changes without affecting
directory pages.

## Respecting the existing TOC configuration

The theme supports a global setting and a page override:

```toml
[params]
  toc = true
  tocOpen = true
```

A page can opt out with:

```yaml
toc: false
```

`single.html` now resolves whether the TOC is enabled before it creates the
layout:

```go-html-template
{{ $tocEnabled := .Site.Params.toc }}
{{ if isset .Params "toc" }}
    {{ $tocEnabled = .Params.toc }}
{{ end }}
```

This calculation mirrors the theme partial's precedence rule. It is needed in
the parent template because CSS must know whether a second column exists. If the
page disables its TOC, the template omits both the `<aside>` and the
`man-document-layout-with-toc` class, leaving a normal centered reading column.

## Splitting a document into grid areas

The manual document now has three explicit regions:

```go-html-template
<article class="man-document-layout{{ if $tocEnabled }} man-document-layout-with-toc{{ end }}">
    <div class="man-document-intro">
        {{ partial "man/breadcrumb.html" . }}
        <header class="header man-header">...</header>
    </div>

    {{ if $tocEnabled }}
    <aside class="man-toc" aria-label="{{ T "single.table_of_contents" }}">
        {{ partial "toc.html" . }}
    </aside>
    {{ end }}

    <div class="page-content man-document-content">
        {{ .Content }}
    </div>
</article>
```

The order in the HTML is intentional: introduction, TOC, body. On a narrow
screen those blocks already appear in the desired reading order. CSS needs to
rearrange them only when enough horizontal space is available.

The `<aside>` identifies the outline as content complementary to the article.
Its accessible label reuses the same translated “Sommario” string shown by the
theme partial.

## Creating the right-hand column

The layout styles live in:

```text
assets/sass/_custom.scss
```

The normal theme wrapper is designed for one narrow reading column. Only manual
documents are widened:

```scss
.wrapper.man-document-page {
  max-width: 1080px;
}
```

When a TOC exists, the article becomes a two-column grid:

```scss
.man-document-layout-with-toc {
  column-gap: 3.5rem;
  display: grid;
  grid-template-areas:
    "document-intro toc"
    "document-content toc";
  grid-template-columns: minmax(0, 720px) minmax(13rem, 15rem);
  grid-template-rows: auto 1fr;
}
```

The reading column can shrink without overflowing because its minimum is zero.
The TOC remains between 13 and 15 rem, which is enough for section labels
without competing with the article for most of the page.

The named areas keep the title and body in the first column and make the TOC
span the right side:

```scss
.man-document-intro {
  grid-area: document-intro;
}

.man-document-content {
  grid-area: document-content;
}

.man-toc {
  grid-area: toc;
}
```

## Making the outline follow the viewport

The grid item keeps the right column reserved, while the `<details>` inside it
uses `position: fixed`:

```scss
.man-toc {
  grid-area: toc;
}

.man-toc .toc {
  max-height: calc(100vh - 7rem);
  overflow-y: auto;
  position: fixed;
  top: 5.5rem;
  width: 15rem;
}
```

The distinction is deliberate. A sticky element follows the viewport only
inside the scroll range of its containing block. The requested behavior is for
the outline to remain at the same screen position throughout scrolling, so the
menu itself is fixed to the viewport.

The empty `.man-toc` grid item still occupies the second column. This prevents
the reading column from expanding underneath the fixed menu. Because horizontal
insets remain automatic, the fixed `<details>` keeps the static horizontal
position supplied by that grid column; only its vertical position is pinned.

The maximum height prevents a long outline from extending beyond the viewport.
If the outline itself is taller, only its column becomes scrollable.

## Restyling the theme block in the sidebar

The theme's inline TOC uses a filled background, padding, and normal list
indentation. Those choices work for a dropdown inside an article but make a
sidebar visually heavy. Manual-specific selectors remove the card treatment on
wide screens:

```scss
.man-toc .toc {
  background: transparent;
  border-radius: 0;
  margin: 0;
  padding: 0;
}

.man-toc #TableOfContents ul {
  list-style: none;
  margin: 0.65rem 0 0;
  padding: 0;
}
```

Nested headings receive a subtle left border, and links use the quieter gray
text color until hover or keyboard focus. Matching dark-mode rules use the
theme's existing dark variables rather than hard-coded duplicate colors.

The `<details>` and `<summary>` remain intact. The TOC is open by default because
`tocOpen = true`, but a reader can still collapse it.

## Responsive fallback

The fixed sidebar layout stops at 1152 pixels:

```scss
@media screen and (max-width: $on-widescreen) {
  .man-document-layout-with-toc {
    display: block;
  }

  .man-toc .toc {
    max-height: none;
    overflow: visible;
    position: static;
    width: auto;
  }
}
```

Because the HTML places the aside between the intro and body, switching the
article back to block layout produces:

```text
breadcrumb and title
collapsible TOC
document body
```

The filled background and padding are restored at this breakpoint, making the
control recognizable as the compact dropdown already used by the theme. This
fallback also covers touch devices where a narrow fixed sidebar would be harder
to use.

## What was not changed

The implementation did not:

- modify the theme submodule;
- duplicate the theme's `toc.html` partial;
- generate a second outline from Markdown;
- add scroll-tracking JavaScript;
- change `layouts/man/list.html` into a document template;
- force a blank sidebar onto pages with `toc: false`.

The change is therefore a layout override around Hugo's existing page data and
the theme's existing TOC behavior.

## Verification

The production build was regenerated with:

```bash
hugo --cleanDestinationDir --printPathWarnings
```

The generated document HTML was checked for:

- `man-document-layout-with-toc` only when the TOC is enabled;
- one semantic `<aside class="man-toc">`;
- one `#TableOfContents` generated by Hugo;
- the introduction, aside, and body in responsive source order;
- fixed positioning for the TOC menu on wide screens;
- static positioning below the widescreen breakpoint;
- the original `<details open>` behavior from `tocOpen = true`;
- no right-hand column on directory list pages;
- no build or path warnings.
