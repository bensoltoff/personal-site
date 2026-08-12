# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Benjamin Soltoff's personal website: a **Quarto** website with an R (knitr) engine, styled from a single
`_brand.yml`, rendered to `docs/` and served by GitHub Pages. It was migrated from Hugo + blogdown; if you
find instructions referring to `hugo`, `blogdown`, `config.toml`, or `content/`, they are stale.

## Commands

```bash
quarto preview          # local server with live reload
quarto render           # full build into docs/
quarto render blog/<slug>/index.qmd   # single post
```

R dependencies are managed with **renv**. `.Rprofile` activates it automatically, so a plain `quarto
render` uses the project library. After adding a package: `renv::snapshot()`. The lockfile uses snapshot
type `all` because renv's dependency discovery is unreliable for a site whose packages appear only inside
`.qmd` chunks.

## Execution model: freeze *and* cache, deliberately

Both are on, and they do different jobs. Do not remove one thinking it duplicates the other.

- **`execute: freeze: auto`** (`_quarto.yml`) — stops a post re-executing *across* renders. A post only
  re-runs when its own `.qmd` changes. This is what keeps decade-old posts from being re-run on every
  build. `_freeze/` is **committed**; without it, a fresh clone re-executes everything.
- **`cache: true`** (`blog/_metadata.yml`) — knitr chunk caching, which stops expensive chunks re-running
  *within* a render you did trigger. Several posts run Monte Carlo simulations taking minutes
  (`can-you-find-the-best-dungeons-dragons-strategy` spends ~5 minutes in one chunk). Without cache,
  fixing a typo means re-running the simulation. `*_cache/` is gitignored — it is a local accelerator
  only, and it is large (200MB+).

Chunks that depend on data produced by an earlier chunk need `dependson`, because knitr keys the cache on
a chunk's own source text, not its upstream inputs. Most posts already declare this.

## Old posts are frozen artifacts, not live code

Posts date back to 2014 and were last rendered in 2021 under R 4.0.4 with ggplot2 3.3.3. They now run
under whatever `renv.lock` pins. Two consequences:

1. **Don't casually re-execute an old post.** Deleting its `_freeze/` entry means re-running 2016 code
   against modern packages, and the output may legitimately differ from what is published.
2. **If you must change old code to make it run, say so in the post.** The convention is a callout
   directly beneath the front matter naming the specific change:

   ```markdown
   ::: {.callout-note}
   ## Code updated

   This post was originally written in 2016 and was last rendered under R 4.0.4. The code has been
   minimally updated to run under R 4.6.1: `dplyr::tbl_df()`, defunct since dplyr 1.0.0, was replaced
   with `tibble::as_tibble()`. The analysis and its conclusions are unchanged.
   :::
   ```

Four posts (`the-forrest-bounce-...`, `valuing-timeouts-in-football`, `...-part-ii`,
`do-cops-pull-over-...`) have **no R source at all** — the originals were lost before the blogdown era.
They carry `engine: markdown` so knitr never runs, and their figures are committed PNGs sitting in the
post directory. Do not add executable chunks to them.

`blog/_metadata.yml` deliberately leaves `warning: true` and `message: true`: the published Hugo posts
show join messages and deprecation warnings inline, and suppressing them would silently change what these
posts look like.

## URLs are load-bearing

The site has been live for a decade. Post directories are named by **slug**, not date, so
`blog/<slug>/index.qmd` serves `/blog/<slug>/` exactly as Hugo did. Root pages (`about.qmd` etc.) render
to `/about.html` and carry `aliases:` to keep `/about/` working.

Every post's `aliases:` list carries its legacy `/post/...` and `/r/...` URLs — 24 of them. Quarto turns
each into a JS-redirect page in `docs/`. **Don't drop an alias when editing front matter.** Note aliases
must not name the page's own URL; that collides with the real output file.

`R/post-render.R` copies `docs/blog/index.xml` to `docs/index.xml`, because Hugo published a site-root
feed that Quarto has no native equivalent for, and it recreates `docs/.nojekyll` (Quarto wipes the output
directory each render).

## Layout

```
_quarto.yml     project config; render list is scoped to **/*.qmd
_brand.yml      palette + typography (the old hugo-apero "plum" theme, preserved)
custom.scss     what brand.yml can't express: type scale, uppercase nav, square buttons
blog/           index.qmd is the listing; each post is blog/<slug>/index.qmd
project/        index.qmd is a grid listing; each project is project/<name>/index.qmd
docs/           build output, COMMITTED (GitHub Pages serves it)
_freeze/        execution cache, COMMITTED
temp/           standalone Riddler scratch scripts, unrelated to the build
```

`docs/` and `_freeze/` are both tracked on purpose. Committing build output is unusual, but it is what
lets GitHub Pages serve the site without running R in CI.
