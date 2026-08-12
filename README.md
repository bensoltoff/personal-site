# personal-site

[Quarto](https://quarto.org) website for [bensoltoff.com](https://www.bensoltoff.com), with R (knitr)
for the blog posts.

```bash
quarto preview   # local server with live reload
quarto render    # build into docs/
```

R dependencies are pinned with [renv](https://rstudio.github.io/renv/); `.Rprofile` activates the
project library automatically.

`docs/` and `_freeze/` are both committed on purpose: GitHub Pages serves `docs/`, and `_freeze/` keeps
the older posts from re-executing on every build. See `CLAUDE.md` for how the site fits together.
