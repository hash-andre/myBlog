---
title: "Blog engineering log"
linkTitle: "blog"
description: "Detailed decisions, changes, failures, and verification steps behind this website"
weight: 10
---

This directory is the engineering log for the website itself.

The purpose is not only to record the final configuration. Each entry explains
the problem that triggered a change, the alternatives considered, the files
involved, the implementation, and the checks used to decide that the work was
complete. Failed assumptions are useful here too: they explain why the current
solution exists and prevent the same investigation from being repeated later.

Every log is stored once, as a page under `man`. Because it also has
`show_in_posts: true`, the same canonical page appears in the chronological
`posts` timeline without duplicating its Markdown.

A root `README.md` will eventually provide a short setup and contribution
guide. It should remain an entry point, while this directory remains the
detailed source of truth and the historical record.
