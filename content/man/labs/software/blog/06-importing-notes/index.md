---
title: "06 — Importing Markdown notes from ZIP archives"
description: "The technical failure modes between a Markdown export and a valid, repeatable Hugo import"
date: 2026-08-29T19:10:00+02:00
show_in_posts: true
weight: 70
---

## From bundle design to an import pipeline

The earlier
[page-bundle entry]({{< relref "/man/labs/software/blog/02-page-bundles-and-notion-imports" >}})
established the destination rule: every document lives in a leaf bundle with
its `index.md` and its own resources. That solves the storage problem, but it
does not make a ZIP export safe to copy directly into `content/`.

An archive is a transport format. It can contain an extra wrapper directory,
another ZIP, several Markdown files, generic image names, percent-encoded links,
and exporter-specific HTML. Hugo expects a much stricter input contract.

The import therefore needs an explicit boundary:

```text
unchanged ZIP
    -> temporary extraction
    -> inventory and path mapping
    -> Markdown normalization
    -> complete leaf bundle
    -> Hugo build and output checks
```

The note's subject is not the difficult part of this pipeline. The difficult
part is preserving the relationship between Markdown and resources while their
names, paths, and container structure change.

## A ZIP does not expose a predictable root

Two exports made by the same application can have different shapes:

```text
export-a.zip                 export-b.zip
├── Note.md                    └── ExportBlock.zip
└── Note/                         ├── Note.md
    └── image.png                  └── Note/
                                        └── image.png
```

An importer that assumes “the first Markdown file is the page” or “resources
are one directory below the archive root” works only for one export shape. The
archive must be inventoried before target directories are created.

A first inspection can list members without extracting them:

```bash
unzip -Z1 export.zip
```

The inventory needs to answer:

- is the archive wrapped in another archive or directory?
- how many Markdown documents are present?
- which resource directory belongs to each document?
- do different directories contain files with the same basename?
- are there absolute paths, `..` segments, or symbolic links that should not be
  extracted?

Extraction happens only inside a temporary staging directory. Unknown archives
must not be expanded directly into the repository: malformed member paths can
escape an intended destination, and even a normal export can overwrite a file
whose name happens to collide.

## Filesystem paths and Markdown URLs are different things

The ZIP stores filesystem names, while Markdown stores URLs. A space may appear
as a literal space in the archive and as `%20` in the link:

```text
ZIP member:    My note/image 1.png
Markdown URL:  My%20note/image%201.png
```

Comparing those strings directly reports a missing file even though the
resource exists. The import must normalize them into a common internal form.
That normally means:

1. parse the Markdown destination as a URL;
2. separate any query string or fragment;
3. decode its path once;
4. normalize separators and relative segments;
5. resolve it relative to the source Markdown file;
6. match that resolved source path against the archive inventory.

Decoding the whole Markdown file with a text replacement is unsafe. It can
change prose, code examples, remote URLs, or a literal `%25`. Decoding twice is
also wrong: `%2520` and `%20` do not represent the same source string.

Unicode adds another edge case. Two filenames can look identical while using
different normalization forms at the byte level. The importer needs one
documented comparison rule and must still preserve a deterministic mapping to
the final ASCII, hyphenated resource name.

## A basename is not a resource identity

Exports frequently reuse names such as:

```text
image.png
image 1.png
image 2.png
```

Using only `image.png` as a lookup key is ambiguous as soon as the archive
contains more than one page. The stable source identity is the normalized path
relative to the exported Markdown file, not the basename.

The importer builds a mapping before rewriting anything:

```text
source relative path            target bundle path
----------------------------    --------------------------
My note/image.png               diagram-overview.png
My note/image 1.png             packet-flow.png
```

Target names must also be allocated as a set. If two source resources would
both become `diagram.png`, the conflict is detected before either file is
copied. Silently overwriting the first resource would leave valid-looking
Markdown pointing to the wrong image, which is more dangerous than a build that
fails visibly.

## Link rewriting must be structural

A global search-and-replace for an exported directory name is tempting, but it
does not understand Markdown syntax. The same text might occur in prose, a code
block, an external link, or two destinations with different escaping.

The rewrite should operate on parsed link and image destinations. For each local
resource it should:

1. resolve the source destination;
2. require exactly one match in the inventory;
3. look up the allocated target filename;
4. replace only the destination token;
5. preserve an intentional fragment or title;
6. leave remote `http:`, `https:`, `mailto:`, and data URLs alone.

After the bundle is assembled, links become local and relative:

```md
![Diagram of the imported concept](diagram-overview.png)
```

Relative links keep the Markdown and resource together when the whole bundle
moves. They also make a broken import observable without knowing the final site
domain.

## Markdown dialects do not match automatically

The `.md` extension says very little about the exact dialect inside the file.
An exporter can add raw `<aside>` elements, unusual callout markup, nested lists
with inconsistent indentation, duplicated captions, or code fences with an
incorrect language identifier.

There is also a boundary between front matter and content. Hugo already renders
the front matter title as the page `<h1>`, so keeping the exported top-level
heading usually creates a duplicate title. Imported headings need to start at a
level that produces a valid document outline and table of contents.

These transformations are structural:

- add valid Hugo front matter;
- remove only the duplicated document title;
- normalize heading levels without flattening the hierarchy;
- convert exporter-only blocks into Markdown or HTML supported by the site;
- keep code fences balanced and their contents untouched;
- separate meaningful captions from image alt text.

This stage deliberately avoids rewriting the subject matter. Content review is
a separate pass. Mixing editorial changes into path conversion makes it much
harder to tell whether a later diff came from the importer or from an author.

## The bundle should be committed as one unit

Copying `index.md` first and images later creates a temporarily broken page. A
safer importer constructs the entire leaf bundle in staging:

```text
staging/target-bundle/
├── index.md
├── diagram-overview.png
└── packet-flow.png
```

Only after every reference has been resolved is that directory moved into its
final section under `content/`. If one source asset is missing or ambiguous, the
bundle is rejected as a unit. The unchanged ZIP remains available for another
attempt.

Front matter is generated at this boundary because the export does not know the
site's content model:

```yaml
---
title: "Readable title"
description: "Short directory and timeline description"
date: 2026-08-29T19:10:00+02:00
show_in_posts: true
weight: 70
---
```

`weight` controls position in the manual. `date` controls chronological views.
`show_in_posts` opts the canonical manual page into those views. The importer
must not derive one ordering value from another because they describe different
relationships.

## Validation is a graph check

The most useful import check compares two sets inside each completed bundle:

```text
R = local resources referenced by Markdown
F = resource files present beside index.md

missing resources = R - F
unused resources  = F - R
```

Both differences should normally be empty. This catches more than a successful
copy command:

- `R - F` finds broken paths, bad decoding, and resources that were never
  extracted;
- `F - R` finds stale copies, incorrect renames, and files brought over from a
  different page.

The reference scan must understand Markdown and any supported raw HTML. An
`<img src="...">` is still a dependency even though it does not use Markdown
image syntax.

Text-level checks then look for artifacts that should not reach the final
bundle:

```text
%20
export wrapper directory names
source UUIDs
absolute local paths
unresolved ../ segments
```

These are signals, not unconditional replacement targets. A percent sequence or
UUID inside a code sample might be intentional, so every match needs context.

## A successful build is necessary but not sufficient

The final source check is:

```bash
hugo --cleanDestinationDir --printPathWarnings
```

This proves that Hugo can load the content model and render the site without the
path warnings it knows how to report. It does not prove that every image is the
right image or that every URL was rewritten correctly.

Generated HTML must also be inspected for:

- expected `<img src>` values and existing output files;
- duplicate `<h1>` elements;
- malformed table-of-contents nesting;
- links that still point to staging or export paths;
- canonical links that point to the manual bundle;
- inclusion in posts and RSS only when the front matter requests it.

Browser rendering remains useful for visual regressions, but it is the last
check, not the first place where missing-resource logic should live.

## Repeatability matters on the second import

The first import can appear successful even when the procedure is based on
manual guesses. The real test is what happens when the same note is exported
again.

A repeatable pipeline keeps or can reconstruct a manifest containing:

```text
source archive checksum
source Markdown path
source-resource -> target-resource mappings
target bundle path
normalization rules or importer version
```

Given the same input and rules, it should produce the same tree. Given a new
export, the diff should show actual note or resource changes rather than a new
set of arbitrary filenames. Existing reviewed front matter must not be replaced
silently just because the exporter produced another title or timestamp.

That is the larger technical problem behind importing Markdown notes from ZIP:
it is a small data migration. The ZIP supplies files, but the importer must
recover their relationships, translate them into Hugo's content contract, and
prove that the resulting bundle is complete before it becomes source content.
