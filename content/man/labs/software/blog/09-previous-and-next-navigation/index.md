---
title: "09 — Adding previous and next document navigation"
description: "How manual articles gained filesystem-aware links without modifying the theme"
date: 2026-08-31T11:35:00+02:00
show_in_posts: true
weight: 100
---

## The navigation rule

The manual presents content as a filesystem. Each section is a directory and
its immediate children are ordered by their `weight` front matter. Previous and
next links should follow that same local order instead of the global publication
date used by the posts timeline.

For a document such as:

```text
content/man/labs/software/blog/03-one-source-multiple-timelines/index.md
```

the relevant collection is the set of regular pages belonging to the `blog`
parent section. Moving backward selects the preceding sibling; moving forward
selects the following sibling.

## Keeping the theme untouched

The implementation lives in project-level overrides:

```text
layouts/man/single.html
layouts/_partials/man/document-navigation.html
assets/sass/_custom.scss
```

No file inside `themes/hugo-blog-awesome/` is changed. Hugo gives project
layouts priority over theme layouts, so theme updates cannot overwrite the
navigation logic.

## Finding adjacent documents

The partial starts from the current document's parent and obtains its immediate
regular pages:

```go-html-template
{{ $siblings := .Parent.RegularPages.ByWeight }}
```

It finds the current page in that ordered collection. When an item exists
before it, the partial stores it as `previous`; when an item exists after it,
the partial stores it as `next`. The first and last documents naturally expose
only one direction.

This is intentionally different from using the post timeline. A manual article
may appear under `/posts/`, but its reading order remains determined by its
filesystem directory and `weight`.

## Rendering the links

`layouts/man/single.html` renders the partial immediately after the Markdown
content. The generated navigation is a semantic `<nav>` containing links with
`rel="prev"` and `rel="next"`:

```html
<nav aria-label="Navigazione tra i documenti">
  <a rel="prev">← Articolo precedente</a>
  <a rel="next">Articolo successivo →</a>
</nav>
```

Each link also displays the target document title, so the reader knows where
the arrow leads before selecting it.

## Reusing and extending the theme styles

The theme already defines the `.post-nav`, `.post-nav-item`, `.nav-arrow`, and
`.post-title` classes. The project reuses those styles and adds only two small
alignment rules in `_custom.scss`: the previous link stays on the left and the
next link stays on the right. The theme's existing mobile and dark-mode rules
continue to apply.

## Verification

The change is checked in the generated HTML for three cases:

1. the first document has only a next link;
2. a middle document has both previous and next links;
3. the last document has only a previous link.

The targets must match the order displayed by the containing manual directory,
and every generated link must resolve to an existing page.
