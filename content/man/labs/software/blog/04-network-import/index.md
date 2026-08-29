---
title: "04 — Importing the network notes"
description: "How nested Notion exports became ten ordered, reviewed, resource-safe networking articles"
date: 2026-08-29T23:10:00+02:00
show_in_posts: true
weight: 50
---

## Starting state

The networking section already contained the manually prepared OSI article:

```text
00-osi-model/
```

The new Notion exports were stored in archives numbered from `2.zip` through
`10.zip`. Their external numbering did not match the site's lesson numbering.
The instruction was explicit: the first imported archive must become lesson
`01`, because OSI had already become lesson `00`.

The mapping was therefore:

| Source archive | Site bundle |
| --- | --- |
| existing page | `00-osi-model/` |
| `2.zip` | `01-ethernet-physical-layer/` |
| `3.zip` | `02-ethernet-data-link-layer/` |
| `4.zip` | `03-wireless-ieee-802-11/` |
| `5.zip` | `04-hub-switch-arp/` |
| `6.zip` | `05-ipv4/` |
| `7.zip` | `06-vlan-dhcp/` |
| `8.zip` | `07-create-vlan-lab/` |
| `9.zip` | `08-stp-icmpv4/` |
| `10.zip` | `09-routing/` |

Writing this table before copying files prevented an off-by-one naming error
from spreading into titles, weights, URLs, and links.

## Nested ZIP handling

Each numbered archive contained another Notion export ZIP rather than the
Markdown directly. The import therefore had two extraction layers:

```text
2.zip
└── ExportBlock-...-Part-1.zip
    ├── article.md
    └── article resources/
```

The outer archives were inventoried first. Inner archives were extracted into
temporary directories. The original `zip-for-network/` inputs were never
rewritten or used as build content.

## Bundle construction

Every lesson became a leaf bundle:

```text
content/man/network/04-hub-switch-arp/
├── index.md
├── switch-topology.png
└── arp-request-reply.png
```

The actual resource set varies by lesson, but the rules do not:

- one `index.md` per article;
- all article-specific resources beside it;
- no Notion UUID in the public path;
- no spaces or percent encoding in resource filenames;
- relative image references;
- descriptive alt text.

## Ordering and timeline publication

The directory order is controlled by weights in increments of ten:

```yaml
weight: 50
```

Every article also received a real chronological date and:

```yaml
show_in_posts: true
```

This made all ten lessons available through both the hierarchical network
manual and the chronological post/RSS views without copying them.

## Markdown cleanup

The raw exports needed more than path replacement. The review included:

- removing the duplicated top-level title;
- normalizing headings for a valid table of contents;
- converting Notion callouts into Markdown that Hugo renders predictably;
- repairing broken lists and tables;
- replacing raw YouTube and reference URLs with descriptive links;
- separating captions from alt text where both were useful;
- removing redundant image captions where they repeated the same information;
- checking fenced code and command names;
- correcting obvious spelling and terminology errors.

## Technical review

Networking notes can look structurally correct while teaching a misleading
model. The review therefore checked statements about:

- OSI and TCP/IP layer responsibilities;
- Ethernet frame fields and MTU;
- MAC addressing and switch learning;
- ARP request/reply behavior;
- IPv4 header fields, CIDR, subnetting, and fragmentation;
- VLAN separation, trunking, and DHCP;
- spanning tree, broadcast storms, and ICMPv4;
- routing decisions and gateway behavior.

The goal was not to turn study notes into a standards document. It was to keep
the direct learning style while removing statements that could create the wrong
mental model later.

## Mathematics

Four lessons contain expressions such as subnet-bit calculations. They received:

```yaml
math: true
```

This tells the theme to load KaTeX only for pages that need it. Loading the
library globally would make every page pay for functionality it does not use.

The affected lessons are:

- Ethernet Data Link;
- IPv4;
- VLAN and DHCP;
- STP and ICMPv4.

## Results and verification

The completed network section contained ten regular pages and 53 non-page
resources. Validation checked:

1. every image reference resolves inside its page bundle;
2. every copied resource is referenced;
3. no `%20`, Notion UUID, or exported directory path remains;
4. all ten articles appear in `/posts/` in reverse date order;
5. all ten canonical `/man/network/.../` URLs appear in RSS;
6. mathematical pages include KaTeX and non-mathematical pages do not;
7. the Hub/Switch/ARP table of contents contains named entries rather than an
   empty bullet;
8. the Hugo build completes without path warnings.

The section is now extensible: the next lesson can be added as bundle `10-.../`
with the next weight, while the current URLs remain stable.
