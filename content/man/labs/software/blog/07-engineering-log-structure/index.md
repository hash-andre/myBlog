---
title: "07 — Turning blog documentation into an engineering log"
description: "Why the technical blog became a directory and how future logs should be written"
date: 2026-08-29T23:50:00+02:00
show_in_posts: true
weight: 80
---

## The previous shape

Technical documentation originally lived in one file:

```text
content/man/labs/software/blog/
└── index.md
```

This was a Hugo leaf bundle: one readable page, optionally accompanied by its
resources. It worked while the documentation was short, but it mixed unrelated
layers:

- initial project motivation;
- content architecture;
- Notion import rules;
- post aggregation;
- favicon and math fixes;
- network and Odin import reports;
- local build commands.

Adding more headings would make the table of contents longer without producing
a useful history. More importantly, a leaf bundle cannot contain descendant
pages. The filesystem shape was contradicting the new requirement.

## The branch conversion

The directory now uses `_index.md`:

```text
content/man/labs/software/blog/
├── _index.md
├── 00-building-the-blog/
│   ├── index.md
│   └── resources...
├── 01-content-architecture/
│   └── index.md
└── ...
```

This turns `blog/` into a Hugo branch bundle. The branch page provides the
purpose of the directory and the manual template lists each immediate log. Each
log remains a leaf bundle so it can carry screenshots or diagrams beside its
Markdown.

## Why logs instead of one living document

A single living document is good at describing the current state. It is weak at
explaining how that state emerged. An engineering log preserves both:

- the trigger or symptom;
- the assumptions made at that moment;
- the alternatives rejected;
- the exact implementation;
- the verification evidence;
- the lesson that should influence future changes.

This is especially useful when the same symptom can have several causes. “The
favicon is missing” could mean a wrong asset name, a wrong template lookup path,
a stale build, a wrong URL, or browser cache. A log records which cause was
actually observed here.

## Naming and ordering

Log directories use a numeric prefix and a descriptive slug:

```text
07-engineering-log-structure/
```

The prefix makes the source tree readable without relying on front matter. The
front matter `weight` separately controls the manual view:

```yaml
weight: 80
```

Weights use increments of ten so a related entry can be inserted later without
renumbering every existing page.

The page title repeats the sequence number for visible context:

```yaml
title: "07 — Turning blog documentation into an engineering log"
```

## Chronology without duplication

Every engineering log is both technical documentation and a record of work. It
therefore receives:

```yaml
date: 2026-08-29T23:50:00+02:00
show_in_posts: true
```

The canonical content remains under `man/labs/software/blog`. The shared
timeline partial makes it appear under `posts`, home, and RSS. No second
Markdown file is created.

This gives the two useful orders again:

- `weight` represents the conceptual sequence inside the engineering manual;
- `date` represents when the work was documented.

## Standard front matter for a new log

```yaml
---
title: "08 — Short description of the change"
description: "What problem this log explains"
date: 2026-08-30T10:00:00+02:00
show_in_posts: true
weight: 90
---
```

The date must include the local UTC offset. The title and description should
describe the outcome, not use a vague label such as “updates”.

## Standard reasoning structure

A future log should normally answer these questions in order:

1. **What did I observe?** Include the visible symptom or missing capability.
2. **What should the system do?** State the desired behavior precisely.
3. **What owns that behavior?** Identify content, configuration, template,
   asset pipeline, generated output, browser, or deployment.
4. **What evidence identified the cause?** Include relevant source snippets or
   generated HTML, not only the conclusion.
5. **What changed?** Name files and explain the role of each change.
6. **Why this solution?** Record trade-offs and rejected alternatives.
7. **How was it verified?** State commands, counts, paths, and expected output.
8. **What remains?** Separate a real follow-up from work that is already done.

Not every entry needs exactly these headings, but it should preserve this chain
of reasoning. The reader should be able to reconstruct the decision without
access to the original conversation.

## Source snippets and generated files

Logs should quote the smallest source snippet that explains a mechanism. Large
files become stale when copied wholesale into documentation.

Generated files under `public/` can be cited as verification evidence, but they
are not the implementation source. A log should always point first to the
content, layout, asset, or configuration that owns the result.

## Relationship with a future README

A README and an engineering log solve different problems.

The future root `README.md` should be concise:

- what the project is;
- prerequisites;
- how to clone the theme submodule;
- how to run the local server;
- how to perform a production build;
- the high-level content tree;
- links to detailed documentation.

It should not duplicate the complete history of favicon debugging, archive
mapping, or Markdown cleanup. Those details belong here. The README can link to
the relevant published log or source path.

This separation keeps onboarding fast without discarding the reasoning that
makes maintenance safe.

## Definition of done for this conversion

The directory conversion is complete when:

- `blog/` contains `_index.md` and no old `index.md` leaf page;
- every log is an immediate leaf bundle with valid front matter;
- the three supplied screenshots belong to the first log bundle;
- `/man/labs/software/blog/` lists all logs as files;
- every log has a canonical `/man/.../blog/.../` URL;
- every log appears in `/posts/` and RSS exactly once;
- no image path contains the old Notion directory or `%20`;
- the Hugo build completes without warnings;
- the original ZIP remains unchanged.

The result is not the final documentation. It is a structure that makes detailed
documentation sustainable as the site continues to change.
