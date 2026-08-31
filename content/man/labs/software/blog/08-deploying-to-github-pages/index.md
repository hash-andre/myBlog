---
title: "08 — Deploying the Hugo site to GitHub Pages"
description: "Continuous deployment with the workflow recommended by the official Hugo documentation"
date: 2026-08-30T11:20:00+02:00
show_in_posts: false
weight: 90
build:
  render: never
  list: never
---

## Deployment target

This repository is published as a GitHub Pages project site:

```text
Repository: https://github.com/hash-andre/myBlog
Website:    https://hash-andre.github.io/myBlog/
```

The repository is named `myBlog`, so `/myBlog/` is part of the public URL. Hugo
must include this prefix in canonical URLs, stylesheets, images, and internal
navigation.

The repository keeps the production fallback in `hugo.toml`:

```toml
baseURL = "https://hash-andre.github.io/myBlog/"
```

During CI, the workflow uses the URL returned by GitHub Pages instead of
duplicating this value:

```bash
hugo build \
  --gc \
  --minify \
  --baseURL "${{ steps.pages.outputs.base_url }}/" \
  --cacheDir "${{ runner.temp }}/.cache/hugo"
```

## Official deployment procedure

The setup follows the current
[Hugo guide for GitHub Pages](https://gohugo.io/host-and-deploy/host-on-github-pages/).
The procedure is:

1. open **Settings → Pages** in the GitHub repository;
2. select **GitHub Actions** as the publishing source;
3. add `.github/workflows/hugo.yaml`;
4. configure Hugo's image cache to use `:cacheDir/images`;
5. commit and push the source;
6. verify the build and deploy jobs in the Actions page;
7. open the URL reported by the deploy job.

Every later push to `main` starts a new build and deployment automatically. The
workflow can also be started manually with `workflow_dispatch`.

## What the workflow does

The deployment pipeline has two jobs:

```text
build                                      deploy
---------------------------------------    ------------------------------
checkout source and theme submodule        download the Pages artifact
install the required tools                 publish it to GitHub Pages
build the site into public/                report the deployed URL
upload public/ as a Pages artifact
```

The workflow uses the action versions shown by the official guide:

```yaml
actions/checkout@v7
actions/configure-pages@v6
actions/setup-go@v6
actions/setup-node@v6
actions/cache/restore@v6
actions/cache/save@v6
actions/upload-pages-artifact@v5
actions/deploy-pages@v5
```

Go and Node.js are installed only when the repository contains `go.mod` or
`package-lock.json`. Hugo and Dart Sass are installed explicitly so the build
does not depend on the tools preinstalled in `ubuntu-latest`.

The versions used by this repository are:

```yaml
DART_SASS_VERSION: 1.102.0
GO_VERSION: 1.26.5
HUGO_VERSION: 0.165.0
NODE_VERSION: 24.19.0
TZ: Europe/Rome
```

The theme is a Git submodule, so checkout and the explicit initialization step
both use recursive submodules. A fresh Actions runner can therefore obtain
`themes/hugo-blog-awesome` before Hugo starts.

### Selecting Dart Sass in the theme pipeline

The theme's upstream head partial calls `toCSS` without selecting a transpiler.
The default is `libsass`, which is available only in Hugo extended builds. The
official Pages workflow installs the standard Hugo binary and the external Dart
Sass executable, so this site overrides only the theme's head partial at:

```text
layouts/_partials/head.html
```

The local override preserves the theme markup and changes the Sass options to:

```go-html-template
{{ $styleOptions := dict
  "targetPath" "style.css"
  "transpiler" "dartsass"
}}
```

This makes the template use the Dart Sass installation supplied by the official
workflow. It also allows a clean checkout, with no pre-generated resource cache,
to compile the SCSS successfully.

## Permissions and concurrency

The workflow token receives only the permissions needed by GitHub Pages:

```yaml
permissions:
  contents: read
  pages: write
  id-token: write
```

The Pages concurrency group prevents simultaneous publications:

```yaml
concurrency:
  group: pages
  cancel-in-progress: false
```

An active deployment is allowed to finish while a later queued run waits.

## Generated files are not source

The official Hugo guide says not to commit the publish directory. Hugo recreates
`public/` on every build, while `resources/_gen/` and `.hugo_build.lock` are
local generated state. The repository therefore contains:

```gitignore
/public/
/resources/_gen/
/.hugo_build.lock
/commit.log
```

`commit.log` is a local audit file rather than website source, so it is kept on
the workstation but excluded from commits and deployments.

The workflow uploads `public/` as an artifact after the build. It does not add
the generated HTML, CSS, JavaScript, feeds, or processed images to Git.

## Image cache configuration

The guide requires image transformations to follow the cache directory supplied
to Hugo by the runner. In `hugo.toml`:

```toml
[caches]
  [caches.images]
    dir = ":cacheDir/images"
```

The cache restore and save steps use:

```text
${{ runner.temp }}/.cache/hugo
```

This keeps generated resources out of the source tree and lets later workflow
runs reuse cached transformations.

## Internal links on a project site

A root-relative link such as `/man/` points to the account root:

```text
https://hash-andre.github.io/man/
```

That is outside this project site. Content links that must follow the configured
base URL use Hugo's `relref` shortcode instead:

```go-html-template
[Manual]({{</* relref "/man" */>}})
```

Hugo then emits a link below `/myBlog/`. Links produced by `.RelPermalink`,
`pageRef`, and `relLangURL` already follow the active base URL.

## Local verification

Before pushing, the same production URL can be tested without writing generated
files into Git:

```bash
output_dir="$(mktemp -d)"
cache_dir="$(mktemp -d)"

hugo build \
  --gc \
  --minify \
  --baseURL "https://hash-andre.github.io/myBlog/" \
  --destination "$output_dir" \
  --cacheDir "$cache_dir" \
  --printPathWarnings
```

The verification checks that:

- Hugo completes without errors or path warnings;
- canonical URLs use the GitHub Pages project URL;
- stylesheets, icons, images, and internal links retain the `/myBlog/` prefix;
- the theme submodule is available;
- `public/` remains untracked.

## Publishing and verification

Publishing is a normal Git operation:

```bash
git add .
git commit -m "Update site and GitHub Pages deployment"
git push origin main
```

The push triggers the workflow. A deployment is complete only after both jobs
are green and the live site responds correctly:

```text
Actions: https://github.com/hash-andre/myBlog/actions
Site:    https://hash-andre.github.io/myBlog/
```

If `Setup Pages` reports that Pages is not enabled, the repository still needs
the one-time **Settings → Pages → Source → GitHub Actions** selection. If the
site loads without CSS or internal links leave the site, inspect the generated
URLs and confirm that they include `/myBlog/`.

## Ongoing publication flow

```text
edit Markdown, templates, or assets
        ↓
verify the Hugo production build locally
        ↓
commit and push main
        ↓
GitHub Actions builds public/
        ↓
GitHub Pages publishes the artifact
```

The source remains in Git, Hugo remains responsible for the static build, and
GitHub Pages remains responsible for hosting the generated artifact.

References:

- [Hugo: Host on GitHub Pages](https://gohugo.io/host-and-deploy/host-on-github-pages/)
- [GitHub: Using custom workflows with GitHub Pages](https://docs.github.com/en/pages/getting-started-with-github-pages/using-custom-workflows-with-github-pages)
- [GitHub: Configuring a publishing source](https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site)
