---
title: "02 — Page bundles and Notion imports"
description: "How exported Markdown and images are converted into self-contained Hugo documents"
date: 2026-08-05T18:10:00+02:00
show_in_posts: true
weight: 30
---

## The image problem

Notion exports a page as Markdown plus a directory of resources. A typical raw
export looks like this:

```text
ExportBlock-...-Part-1.zip
└── My page <notion-page-id>.md
    My page/
    ├── image.png
    ├── image 1.png
    └── image 2.png
```

The Markdown then refers to paths such as:

```md
![image.png](My%20page/image%201.png)
```

Publishing every image into one global directory would create several
problems:

- generic names such as `image.png` collide;
- the relationship between a document and its resources is lost;
- deleting or moving an article leaves ambiguous orphan files;
- reviewing a path requires searching the entire project;
- two imports can silently overwrite resources with the same name.

## The bundle rule

Every manual article with resources becomes a Hugo leaf bundle:

```text
content/man/network/00-osi-model/
├── index.md
├── network-graph.png
├── osi-vs-tcp-ip.png
└── encapsulation-decapsulation.png
```

`index.md` is the document. The adjacent files are its page resources. The
Markdown uses a relative path:

```md
![Comparison between the OSI and TCP/IP models](osi-vs-tcp-ip.png)
```

Hugo publishes the page and resources under the same URL. Moving the entire
bundle preserves the internal relationship because the link does not depend on
a site-wide image path.

## Preserve the source archive

The ZIP is input evidence, not a work directory. It remains unchanged so the
import can be audited or repeated. Extraction happens in a temporary directory,
and only reviewed output enters `content/`.

This distinction is useful when an export is nested inside another ZIP, as the
Notion exports in this project were. The import process first inventories the
outer archives, then the inner archives, before deciding target paths. It does
not assume that the visible ZIP directly contains Markdown.

## Import procedure

### 1. Inventory before copying

List every archive member and record:

- Markdown filenames;
- resource filenames and formats;
- directory relationships;
- export timestamps;
- whether the ZIP contains another ZIP;
- whether multiple pages share resources.

This prevents copying an unexpected tree directly into the repository.

### 2. Decide the canonical URL

Choose the section and a stable bundle name before rewriting links:

```text
Raw title:    Basic CSS & Flexbox
Bundle:       01-basic-css-flexbox/
Canonical:    /man/labs/software/odin-project/01-basic-css-flexbox/
```

The bundle directory is URL-safe, ordered, and independent of the Notion UUID.

### 3. Create Hugo front matter

Notion does not know the site's ordering or timeline rules, so every imported
page receives explicit front matter:

```yaml
---
title: "01 — Basic CSS e Flexbox"
description: "Selettori, cascade, box model, Flexbox e responsive design"
date: 2026-08-18T13:40:00+02:00
show_in_posts: true
weight: 20
---
```

- `title` is written for readers, not derived blindly from the filename.
- `description` explains the page in directory and metadata views.
- `date` places it in the chronological timeline.
- `show_in_posts` includes the canonical manual page in `posts`.
- `weight` controls its order inside the subject directory.

### 4. Normalize the Markdown hierarchy

The page template already renders the front matter title as `<h1>`. Therefore,
the Markdown body should normally begin at `##`, not repeat the exported `#`
title. Nested headings must not skip levels without a reason.

This matters beyond appearance. Hugo builds the table of contents from the
heading tree. A malformed hierarchy can produce misleading nesting or even an
empty-looking item.

### 5. Rename resources

Names such as `image 17.png` are replaced with names that explain their role:

```text
image.png       -> event-loop.png
image 1.png     -> call-stack-sequence.png
image 17.png    -> align-items-values.png
```

The new names use lowercase ASCII words and hyphens. They avoid spaces and
percent encoding, remain readable in URLs, and make missing references easier
to diagnose.

### 6. Rewrite images and alt text

The raw export:

```md
![image.png](Basic%20Javascript/image%203.png)
```

becomes:

```md
![Call stack, Web API, task queue, and event loop](event-loop.png)
```

Alt text describes the information conveyed by the image. Repeating the
filename adds no value to screen-reader users and gives no context when the
resource fails to load.

### 7. Replace bare links

A URL on its own line is difficult to scan and has a poor accessible name:

```md
https://developer.mozilla.org/en-US/docs/Web/API/Window/fetch
```

The reviewed form states why the reader might open it:

```md
[MDN reference for the Fetch API](https://developer.mozilla.org/en-US/docs/Web/API/Window/fetch)
```

### 8. Repair Notion-specific markup

Notion exports can contain constructs that do not map cleanly to the site's
Markdown renderer:

- `<aside>` blocks;
- bold markers inside fenced code;
- language identifiers that do not match the code;
- duplicated captions below images;
- UUIDs in filenames;
- percent-encoded resource directories;
- HTML and JavaScript mixed inside one code fence.

These are reviewed rather than removed blindly. A callout may become a normal
paragraph or blockquote; a mixed example may need two separate code blocks.

### 9. Review meaning, not only syntax

A successful Hugo build proves that the content can be rendered. It does not
prove that it is correct. Technical notes are checked for:

- code that raises syntax or reference errors;
- outdated command behavior;
- statements that turn a rule of thumb into a false universal rule;
- missing security or accessibility implications;
- examples whose output does not match the code;
- terminology that changes meaning when translated.

The goal is to preserve the author's reasoning while making each step reliable.

## Validation checklist

For each imported collection:

1. every Markdown image reference resolves inside its bundle;
2. every copied resource is referenced, unless intentionally retained;
3. no `%20`, Notion UUID, or exported directory path remains;
4. no bare URL remains;
5. code fences are balanced;
6. the Hugo build completes without path warnings;
7. the generated page contains the expected images and table of contents;
8. the page appears in `/posts/` and `/posts/index.xml` when requested;
9. the source ZIP remains unchanged.

This procedure takes longer than copying the export, but it turns a private
note dump into maintainable site content.
