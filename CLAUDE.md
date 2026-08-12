# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Benjamin Soltoff's personal website: a Hugo site managed with **blogdown**, using the vendored
[hugo-apero](themes/hugo-apero) theme, deployed on Netlify from `main`.

## Build and preview

Hugo is **not on `PATH`**; blogdown manages a pinned copy at
`~/Library/Application Support/Hugo/0.81.0/hugo`. The version is pinned in three places that must stay in
sync: `.Rprofile` (`blogdown.hugo.version`), `netlify.toml` (`HUGO_VERSION`), and that installed directory.

```r
# from the project root, in R
blogdown::serve_site()        # live preview with LiveReload (auto-runs on RStudio startup via .Rprofile)
blogdown::build_site()        # full build: knit changed Rmd/Rmarkdown, then run Hugo into public/
blogdown::build_site(build_rmd = "newfile")  # only knit source files with no/stale output
blogdown::stop_server()
blogdown::check_site()        # diagnose config/version problems
```

blogdown is not currently installed in the system library — `install.packages("blogdown")` first if
`packageVersion("blogdown")` fails. Hugo-only commands (no knitting) go through `blogdown::hugo_build()`
rather than a bare `hugo`, so the pinned binary is used.

`public/` is gitignored; Netlify runs plain `hugo` (see `netlify.toml`) and never runs R.

## The critical build constraint

**Netlify does not execute R.** Blog posts are written as `index.Rmarkdown` and knitted *locally* to
`index.markdown` plus an `index_files/` directory of figures. Both the source and the generated output are
committed to git — Hugo on Netlify only sees the `.markdown`. `config.toml`'s `ignoreFiles` excludes
`\.Rmd$` and `\.Rmarkdown$` from the Hugo build for this reason.

Consequences when editing a post:

- Editing `index.Rmarkdown` alone changes nothing on the live site. Re-knit and commit the regenerated
  `index.markdown` and `index_files/` in the same commit.
- Never hand-edit `index.markdown`; it is generated output.
- Use `.Rmarkdown` (→ Markdown, figures as files) for new R-based posts, matching every existing post.
  `.Rmd` would render to raw HTML instead (`blogdown.method = 'html'` in `.Rprofile`) and lose Hugo's
  Markdown processing. Posts with no R code are plain `.markdown` with no source file.
- Post chunks typically set `knitr::opts_chunk$set(cache = TRUE)`; `*_cache/` is gitignored, so a fresh
  clone re-runs everything.

## Content layout

Every content item is a Hugo **page bundle** — a directory containing `index.*` plus its own assets,
named `content/blog/YYYY-MM-DD-slug/`. A `featured.jpg`/`featured.png`/`featured-hex.svg` in the bundle
becomes the listing thumbnail and social card. Blog permalinks are `/blog/:slug/` (`[permalinks]` in
`config.toml`), driven by the `slug` front-matter field, not the dated directory name.

Section index files (`content/*/_index.md`) hold **no body** — they exist to configure the section's
layout (`layout: list-sidebar`, `list-grid`) and to `cascade:` front matter (author, byline, sidebar
config, comments) onto every page in that section. Change display behavior for a whole section there
rather than per-post.

`content/about/` is unusual: `_index.md` cascades `headless: true` and the actual content lives in three
sibling bundles — `header/`, `main/`, `sidebar/` — each a front-matter-only file that the theme's
`about/list.html` assembles. Bio and title updates (the most common edit in this repo's history) touch all
three.

`mainSections = ["blog", "project", "talk"]` in `config.toml` controls what feeds listings; there is
currently no `talk/` content.

## Theme and overrides

`themes/hugo-apero/` is vendored in-tree (not a git submodule — `.gitmodules` is empty). Treat it as
upstream: put customizations in the project's own `layouts/`, which shadows the theme file-for-file. Only
three overrides exist today:

- `layouts/partials/header.html` — copy of the theme header with `mathjax_support.html` appended
- `layouts/partials/mathjax_support.html` — MathJax v3 config (`[params.math]` selects the renderer)
- `layouts/shortcodes/blogdown/postref.html` — blogdown's cross-reference shortcode

Colors come from `params.theme = "plum"` (a built-in hugo-apero palette); a custom palette would be a
`.scss` file in a project-level `assets/` folder named via `params.custom_theme`.

## temp/

`temp/*.R` holds standalone scratch scripts for FiveThirtyEight Riddler puzzles. They are committed
deliberately and are not part of the site build — several later became blog posts. Don't wire them into
the build or "clean them up."

## Editing config.toml

Site-wide identity (title, social links, menus, analytics, taxonomies, privacy) all lives in
`config.toml`. Header/footer navigation is `[[menu.header]]` / `[[menu.footer]]` entries ordered by
`weight`.
