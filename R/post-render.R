# Runs after `quarto render` (see post-render in _quarto.yml).
#
# Two jobs, both about serving the output from GitHub Pages:
#   1. docs/.nojekyll  -- stops Pages running the output through Jekyll, which
#      would drop directories whose names begin with an underscore. Quarto
#      cleans output-dir on a full render, so this has to be recreated rather
#      than committed once.
#   2. docs/index.xml  -- Hugo published the site feed at /index.xml and the old
#      blog sidebar linked to it. Quarto only emits feeds for listing pages, so
#      copy the blog feed up to the root to keep existing subscribers working.

output_dir <- "docs"

if (!dir.exists(output_dir)) {
  quit(save = "no", status = 0)
}

invisible(file.create(file.path(output_dir, ".nojekyll")))

blog_feed <- file.path(output_dir, "blog", "index.xml")
if (file.exists(blog_feed)) {
  invisible(file.copy(blog_feed, file.path(output_dir, "index.xml"), overwrite = TRUE))
}
