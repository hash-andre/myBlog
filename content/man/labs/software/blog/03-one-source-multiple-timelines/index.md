---
title: "03 — One source, multiple views"
description: "How manual pages also appear in posts, home, and RSS without copying content"
date: 2026-08-23T10:00:00+02:00
show_in_posts: true
weight: 40
---

## The duplication problem

The manual and the post timeline answer different questions:

- `man` answers “where does this subject belong?”;
- `posts` answers “what was published, and when?”.

A networking article belongs permanently under `/man/network/`, but it is also
something I wrote on a specific date. Copying it into `content/posts/` would
make both views easy to build, but it would create two sources of truth.

Once duplicated, the copies can diverge:

- a typo is fixed in one copy but not the other;
- one copy references images the other does not contain;
- search engines see two URLs for the same text;
- dates and descriptions drift;
- deleting one copy leaves uncertainty about which page was canonical.

The solution is to aggregate page objects, not files.

## Canonical storage

A technical article remains in its subject bundle:

```text
content/man/network/05-ipv4/
├── index.md
└── resources...
```

Its front matter opts into chronological views:

```yaml
date: 2026-08-11T15:50:00+02:00
show_in_posts: true
```

The page has one Markdown source and one canonical URL:

```text
/man/network/05-ipv4/
```

The entry shown under `/posts/` links to that URL. It does not create
`/posts/05-ipv4/`.

## The shared page collection

The collection is built in:

```text
layouts/_partials/timeline-pages.html
```

Its complete responsibility is small enough to read at once:

```go-html-template
{{- $standalonePosts := where site.RegularPages "Section" "posts" -}}
{{- $manualEntries := where site.RegularPages "Params.show_in_posts" true -}}
{{- $pages := union $standalonePosts $manualEntries -}}
{{- return $pages.ByDate.Reverse -}}
```

Line by line:

1. `site.RegularPages` excludes section index pages and contains readable leaf
   pages.
2. The first `where` selects pages whose top-level section is `posts`.
3. The second `where` selects any regular page that explicitly opts in.
4. `union` combines and de-duplicates the collections.
5. `ByDate.Reverse` sorts newest first.
6. `return` lets multiple templates consume the exact same collection.

Using `union` matters if a regular post ever also receives
`show_in_posts: true`: it still appears only once.

## Three consumers, one rule

The partial is used by:

```text
layouts/home.html
layouts/posts/list.html
layouts/posts/rss.xml
```

The home page limits the collection to the latest entries. The posts page
groups the same collection into a human-readable archive. The RSS template
serializes it for feed readers.

If each template implemented its own selection rule, the views would eventually
disagree. For example, a page could appear on the website but be missing from
RSS. Centralizing selection means a change to publication policy has one
implementation point.

## Standalone editorial posts

Some writing is chronological by nature and does not belong in a manual
directory. It remains under `content/posts/`:

```text
content/posts/un-contenuto-due-percorsi/
└── index.md
```

These pages are selected automatically by their section and do not need
`show_in_posts`. They can still use a leaf bundle when they have images.

## Dates are now part of the content model

Manual navigation uses `weight`; chronological navigation uses `date`. They are
separate because they represent different orders:

```yaml
date: 2026-08-14T18:20:00+02:00
weight: 100
```

- `weight: 100` can place “09 — Routing” after the previous networking lessons.
- `date` places the same page relative to everything written across the site.

Changing one must not be used as a workaround for the other.

## Removing a page from the timeline

The manual page can remain published while leaving the chronological feed:

```yaml
show_in_posts: false
```

Because the selection explicitly compares against `true`, omitting the field
has the same timeline result. Writing `false` is useful when the exclusion is a
deliberate decision that future maintainers should see.

## Validation

For a page with `show_in_posts: true`, verify all three consumers:

```text
public/index.html
public/posts/index.html
public/posts/index.xml
```

The checks confirm that:

- the title is present where the view should include it;
- the link points to `/man/.../`, not a duplicate `/posts/.../` page;
- reverse chronological ordering matches the front matter date;
- the RSS `<link>` and `<guid>` use the canonical URL;
- the manual browser still places the page according to `weight`.

The important result is not merely that the article is visible twice. It is
that every view refers to the same Hugo page object and therefore to the same
content, resources, metadata, and canonical path.
