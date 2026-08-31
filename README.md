# myBlog

Personal Hugo site for notes, laboratories, and projects about Linux,
networking, systems, and cybersecurity. The source is published at
<https://hash-andre.github.io/myBlog/>.

## Site structure

The site exposes the same content through two complementary views:

- `/man/` is a hierarchical manual modeled after the `content/man/`
  filesystem;
- `/posts/` is a reverse-chronological timeline;
- `/` presents the most recent entries;
- `/whoami/` is a standalone profile page;
- `/posts/index.xml` is the RSS feed.

Manual directories are Hugo branch bundles containing `_index.md`. Documents
are leaf bundles containing `index.md` beside their images and other resources.
The `weight` front matter orders entries inside a directory. A manual document
can also appear in the post timeline by defining a publication date and
`show_in_posts: true`; its canonical URL and source remain under `/man/`.

The shared collection in `layouts/_partials/timeline-pages.html` feeds the home
page, posts page, and RSS output without duplicating content. Project-level
layouts implement the manual browser, breadcrumbs, right-hand table of
contents, and previous/next sibling navigation without editing the theme
submodule.

## Local development

Requirements:

- Hugo 0.165 or newer;
- Dart Sass available as `sass` in `PATH`;
- Git with submodule support.

Clone the repository with its theme and start the development server:

```bash
git clone --recurse-submodules https://github.com/hash-andre/myBlog.git
cd myBlog
hugo server -D
```

`-D` includes drafts but not future-dated pages. Use a date that is not later
than the current time, or add `--buildFuture` only when intentionally previewing
scheduled content.

Create a production build with:

```bash
hugo --gc --minify --cleanDestinationDir
```

Generated `public/`, Hugo's resource cache, and `commit.log` are intentionally
ignored by Git.

## Content workflow

Add a manual directory with an `_index.md`, or add a document as a leaf bundle:

```text
content/man/topic/document/
├── index.md
└── image.png
```

Keep imported Markdown resources inside the same bundle, use relative links,
and validate both the rendered page and every referenced file. Content selected
for the timeline must also be checked on the home page, `/posts/`, and the RSS
feed.

## Deployment

`.github/workflows/hugo.yaml` builds and deploys the site to GitHub Pages on
every push to `main`. The workflow installs pinned Hugo and Dart Sass versions,
checks out the theme submodule, builds with the Pages base URL, and uploads only
the generated artifact.

## Engineering documentation

The implementation history is published inside the blog manual at
[`content/man/labs/software/blog/`](content/man/labs/software/blog/). Its entries
cover project creation, content architecture, page bundles and imports, shared
timelines, rendering fixes, the manual browser, ZIP imports, the right-hand
table of contents, GitHub Pages deployment, and previous/next navigation.

## License

See [LICENSE](LICENSE).
