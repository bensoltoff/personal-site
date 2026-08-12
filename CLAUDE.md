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
air format .            # format R source -- run before every commit
```

Formatting is split across two mechanisms:

- **`air format .`** (CLI) handles `.R` files — here that is `temp/*.R`. It correctly skips the
  renv-generated `renv/activate.R`. Run it before every commit.
- **`.qmd` code cells** are formatted on save in VS Code, via `.vscode/settings.json`: the Quarto
  extension formats `[quarto]` files and `Posit.air-vscode` formats `[r]`. The air *CLI* does not
  reformat R cells inside `.qmd`, so editing a post outside VS Code means formatting it by hand.

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

**Changing the ggplot theme requires wiping the caches.** `theme_set()` in the setup chunk is a global
side effect that knitr's cache cannot see: the plotting chunks' own source is unchanged and their
`dependson` points at data chunks, so they are restored from cache and silently keep their *old* figures.
Editing the theme and re-rendering looks like it worked and changes nothing. After any theme change:

```bash
find blog -maxdepth 2 -type d -name "*_cache" -exec rm -rf {} +
rm -rf _freeze docs .quarto && quarto render
```

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

There is no separate about page — `index.qmd` *is* the about page (Quarto's `trestles` template) and
carries `aliases: [/about/]` for the old Hugo URL.

Hugo published a site feed at `/index.xml`; Quarto only emits feeds for listing pages, so the feed now
lives at `/blog/index.xml` only. This is a deliberate, accepted break.

## Layout

```
_quarto.yml     project config; render list is scoped to **/*.qmd
_brand.yml      palette + fonts (colors/typography from the old "plum" theme)
custom.scss     small: font fallbacks and listing underline rules. Keep it small.
index.qmd       the about page AND the home page
blog/           index.qmd is the listing; each post is blog/<slug>/index.qmd
project/        index.qmd is a grid listing; each project is project/<name>/index.qmd
docs/           build output, COMMITTED (GitHub Pages serves it)
_freeze/        execution cache, COMMITTED
.nojekyll       stops GitHub Pages running the output through Jekyll
temp/           standalone Riddler scratch scripts, unrelated to the build
```

`docs/` and `_freeze/` are both tracked on purpose. Committing build output is unusual, but it is what
lets GitHub Pages serve the site without running R in CI.

The layout is stock Quarto — resist rebuilding the old Hugo theme's layouts in `custom.scss`.

## `_brand.yml` is read by two different consumers

Quarto reads it for site styling, and the **brand.yml R package** reads the same file to theme plots via
`brand.yml::theme_brand_ggplot2()`, which posts call in their setup chunk. Their schemas are not
identical, so:

- **Do not add `color.link` or `typography.link`.** Quarto accepts them; the R package errors with
  `Unexpected fields in color: "link"`, which breaks every plot. Links fall back to `primary`.
- **Do not set `typography.monospace.family` to a bare family name.** It emits `font-family: Consolas`
  with no fallback, so machines without Consolas drop to the browser's default *serif* for code. Leaving
  it unset gives Quarto's sans-serif monospace stack, which is what the old site had.

The R package needs `prismatic` installed; it is a soft dependency that `theme_brand_ggplot2()` requires
at call time.

### Fonts in plots take three pieces, not one

`theme_brand_ggplot2()` (brand.yml 0.1.0) is **colors only** — its function body never mentions `family`
or `font`. Setting `source: google` in `_brand.yml` does *not* change this. So plot fonts are wired up
separately, and all three pieces are required:

1. `knitr: opts_chunk: dev: ragg_png` in `_quarto.yml`. ragg renders via systemfonts; the default
   grDevices `png` cannot see fonts registered at runtime.
2. `systemfonts::register_variant(...)` in each plotting post's setup chunk, naming the weights the site
   uses — Commissioner **Light** and Fraunces 72pt Soft **Light**.
3. An explicit `theme(text = element_text(family = "Commissioner Light"), plot.title =
   element_text(family = "Fraunces Soft Light"))` added to the brand theme.

Remove any one of the three and plots silently fall back to the device default sans-serif — no error.

**The setup chunk in `blog/_setup.qmd` must stay `cache: false`.** `register_variant()` is a *session
side effect*, not a value. If that chunk is cached, a cache hit restores the `brand_theme` function
object but never re-runs the registration, so the font alias does not exist in that session and every
plot title silently falls back. The failure looks like "the theme stopped working" and appears only on
re-renders, never on a clean build.

**Install the static TTF builds of both families, not the variable-font builds.** Under ragg the variable
builds ignore their weight axis entirely: `register_variant(weight = "ultralight")` and
`weight = "heavy")` render identically, so plot titles come out in a heavy display weight that clashes
with the site's thin headings. With the static builds installed, `weight = "light"` resolves to
`Commissioner-Light.ttf` and `Fraunces_72pt_Soft-Light.ttf` and the plots match the site.

Note the family is `Fraunces 72pt Soft` (the static name), not `Fraunces` — plain `Fraunces` resolves to
the variable file. Also note "Thin" registers under weight `light`, not `ultralight`, in this family.
