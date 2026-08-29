# Content architecture

This site uses Hugo sections and page bundles to separate chronological posts
from the hierarchical manual.

This file is a compact repository-side overview. The detailed reasoning,
implementation history, and verification steps live in the published
engineering log under:

```text
content/man/labs/software/blog/
```

In particular:

- `01-content-architecture/` explains sections and filesystem navigation;
- `02-page-bundles-and-notion-imports/` defines the import procedure;
- `03-one-source-multiple-timelines/` explains post aggregation;
- `07-engineering-log-structure/` defines how future logs are written.

## Site areas

- `/` is the landing page.
- `/posts/` is an aggregated chronological timeline.
- `/man/` is a directory-style technical manual.
- `/whoami/` is a standalone presentation page.

## Manual navigation

The manual behaves like a small file browser:

1. `/man/` lists only its immediate directories: `thoughts/`, `labs/`,
   `network/`, and `os/`.
2. Opening a directory displays only its immediate contents.
3. A directory may contain other directories and document pages.
4. Opening a document displays its Markdown content.

The browser has two columns: the entry name and its description. Directory
names end with `/`, so a separate type column is unnecessary. Entries are
ordered by the `weight` value in their front matter.

## Branch bundles: directories

Every navigable directory is a Hugo branch bundle and contains `_index.md`:

```text
content/man/network/
├── _index.md
├── 00-osi-model/
└── 01-ethernet/
```

Use this front matter when adding a directory:

```yaml
---
title: "network"
linkTitle: "network"
description: "Fundamentals, protocols, and network labs"
weight: 30
---
```

The body below the front matter is displayed above the directory listing.

## Leaf bundles: documents and images

Every manual document is a Hugo leaf bundle. Its directory contains `index.md`
and all resources belonging to that document:

```text
content/man/network/00-osi-model/
├── index.md
├── osi-layers.png
└── encapsulation.svg
```

Use this front matter for a document:

```yaml
---
title: "00 — OSI model"
description: "The seven layers of the OSI model"
weight: 10
---
```

Reference an image with a relative path:

```md
![OSI layers](osi-layers.png)
```

Hugo publishes the document and its bundled resources under the same URL.
This keeps images exported from Notion next to the Markdown file that uses
them, instead of placing every image in one global directory.

## Adding content exported from Notion

1. Create a leaf-bundle directory in the appropriate manual section.
2. Rename the exported Markdown file to `index.md` and move it into that
   directory.
3. Move the exported images into the same directory.
4. Update the image references in `index.md` to use relative filenames.
5. Add `title`, `description`, and `weight` to the front matter.

## Posts

Posts may also use leaf bundles when they have images:

```text
content/posts/my-post/
├── index.md
└── cover.png
```

Post front matter must include a `date` so `/posts/` can sort entries
chronologically. Set `draft: true` while writing and remove it when the post is
ready to publish.

Standalone pages below `content/posts/` are included automatically. A canonical
page stored in `man` can also appear in the same timeline without copying its
content. Add these properties to its front matter:

```yaml
date: 2026-08-29T22:44:00+02:00
show_in_posts: true
```

The home page, `/posts/`, and `/posts/index.xml` all consume the same Hugo page
collection. Each timeline entry links to the original page in `man`, where its
Markdown and bundled resources remain stored.

## Local preview and production build

Preview drafts locally:

```bash
hugo server --buildDrafts
```

Generate the production site in `public/`:

```bash
hugo --cleanDestinationDir
```

The eventual root `README.md` should remain a concise onboarding guide and link
to this overview and the engineering log instead of duplicating their detail.
