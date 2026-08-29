---
title: "01 — Content architecture and filesystem navigation"
description: "How nested Hugo sections became a manual that behaves like a directory tree"
date: 2026-08-29T20:30:00+02:00
show_in_posts: true
weight: 20
---

## The requirement

The root of the website has four different responsibilities:

- `/` is a landing page, not a complete content archive;
- `/posts/` is the chronological history of published writing;
- `/man/` is a hierarchical manual;
- `/whoami/` is a standalone presentation page.

A date works well when the question is “what did I write recently?”. It does
not work when the question is “where are my notes about routing?”. The manual
therefore needs stable subject-based paths, while the post archive needs dates.

## Why `_index.md` changes a directory

In Hugo, a top-level content directory is a section. A nested content directory
becomes a nested section when it contains `_index.md`. A section is more than a
path segment: it has a list page, logical ancestors and descendants, and a page
object that templates can navigate.

That distinction gives the manual its directory semantics:

```text
content/man/
├── _index.md
├── thoughts/
│   └── _index.md
├── labs/
│   ├── _index.md
│   └── software/
│       ├── _index.md
│       ├── blog/
│       │   └── _index.md
│       └── odin-project/
│           └── _index.md
├── network/
│   └── _index.md
└── os/
    └── _index.md
```

Each `_index.md` is the index page of a branch bundle. It can contain front
matter and explanatory Markdown:

```yaml
---
title: "network"
linkTitle: "network"
description: "Fondamenti, protocolli e laboratori di rete"
weight: 30
---
```

- `title` is the page title.
- `linkTitle` is the shorter label used in navigation.
- `description` explains the directory in the file browser.
- `weight` controls ordering within the parent section.

## Branch bundles and leaf bundles

The manual uses two kinds of page bundle:

```text
branch bundle                 leaf bundle
--------------------------    --------------------------
network/                      00-osi-model/
├── _index.md                 ├── index.md
├── 00-osi-model/             ├── network-graph.png
└── 01-ethernet-.../          └── osi-vs-tcp-ip.png
```

A branch bundle uses `_index.md` and may have descendants. A leaf bundle uses
`index.md`, represents one document, and has no descendant pages. The leading
underscore is therefore meaningful: it is not a naming preference.

The same distinction now applies to the blog engineering log. When `blog/`
contained `index.md`, it was a single leaf page and could not contain other log
pages. Replacing it with `_index.md` turned it into a branch that can list log
leaf bundles.

## Why the theme default was not enough

The theme is optimized for blog lists. The manual needs a different list
behavior:

1. `/man/` should show only its immediate directories.
2. A subsection should show only its immediate children.
3. A directory name should end with `/`.
4. A page should look like a file.
5. Each row should contain only a name and description.
6. Opening a row should navigate into that directory or file.

The implementation lives in project templates, leaving the theme submodule
unchanged:

```text
layouts/
├── man/
│   ├── list.html
│   └── single.html
└── _partials/man/
    ├── breadcrumb.html
    └── entries.html
```

Project templates take precedence over theme templates. This is important for
maintenance: updating the submodule does not overwrite the manual templates,
and the diff contains only the site-specific behavior.

## Selecting the correct directory entries

The list template starts from the current page's immediate children:

```go-html-template
{{ $entries := .Pages }}
```

At the root of `man`, only sections should appear, so it uses `.Sections`:

```go-html-template
{{ if .Parent.IsHome }}
    {{ $entries = .Sections }}
{{ end }}
```

This avoids a recursively flattened manual. Recursion would expose every file
on the first screen and destroy the feeling of navigating a filesystem.

The entry partial receives the page collection and produces one link per
immediate child. Section labels receive a trailing slash, while regular pages
keep their title. The separate “type” column was removed because the slash is
already a compact and familiar type signal.

## Breadcrumbs from Hugo ancestry

Because each directory is a real section, Hugo knows its ancestors. The
breadcrumb partial can derive a path rather than maintaining one manually:

```text
man / labs / software / blog / 01 — Content architecture
```

This is one of the concrete benefits of `_index.md`. Plain nested directories
can contribute URL segments, but they do not necessarily create the logical
page ancestry needed for list pages and breadcrumbs.

## Separating list and single templates

`layouts/man/list.html` renders branch pages. It displays:

1. the breadcrumb;
2. the section title with a trailing slash;
3. the section description and optional body content;
4. the two-column directory browser.

`layouts/man/single.html` renders leaf documents. It displays:

1. the breadcrumb;
2. title and description;
3. the table of contents;
4. the rendered Markdown body.

The content model and the template model now agree: branches are navigated,
leaves are read.

## Current result

The manual tree can grow without changing the root page. To add a new
directory, create a branch bundle. To add a document, create a leaf bundle. The
list template discovers the new child through Hugo's page graph.

That is the core rule of the architecture: the filesystem describes the
information hierarchy, Hugo turns that hierarchy into page relationships, and
the templates expose only the current directory.

## Verification

After changing the structure, the important checks are:

```bash
hugo --cleanDestinationDir --printPathWarnings
```

Then inspect the generated pages and confirm that:

- `/man/` contains only immediate directories;
- each nested directory has its own URL and list page;
- leaf pages use the single-page template;
- breadcrumbs follow the real ancestry;
- no old singular paths such as `/man/lab/` or `/man/thought/` remain.

References:

- [Hugo sections](https://gohugo.io/content-management/sections/)
- [Hugo page bundles](https://gohugo.io/content-management/page-bundles/)
