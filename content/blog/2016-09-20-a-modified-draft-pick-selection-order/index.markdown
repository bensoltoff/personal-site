---
title: A Modified Draft Pick Selection Order
author: ''
date: '2016-09-20'
slug: a-modified-draft-pick-selection-order
aliases: [
  "/r/expected-draft-pick/",
  "/post/a-modified-draft-pick-selection-order/",
  ]
categories:
  - r
tags:
  - r
  - riddler
subtitle: ''
summary: ''
authors: []
featured: no
image:
  caption: ''
  focal_point: ''
  preview_only: no
projects: []
---



In preparation for teaching a [new computing course for the social sciences](https://cfss.uchicago.edu), I've been practicing building interactive websites using [Shiny](http://shiny.rstudio.com/) for R. The [latest Riddler puzzle from FiveThirtyEight](http://fivethirtyeight.com/features/how-high-can-count-von-count-count/) was an especially interesting challenge, combining aspects of computational simulation and Shiny programing:

> You are one of 30 team owners in a professional sports league. In the past, your league set the order for its annual draft using the teams’ records from the previous season — the team with the worst record got the first draft pick, the team with the second-worst record got the next pick, and so on. However, due to concerns about teams intentionally losing games to improve their picks, the league adopts a modified system. This year, each team tosses a coin. All the teams that call their coin toss correctly go into Group A, and the teams that lost the toss go into Group B. All the Group A teams pick before all the Group B teams; within each group, picks are ordered in the traditional way, from worst record to best. If your team would have picked 10th in the old system, what is your expected draft position under the new system?
    
> Extra credit: Suppose each team is randomly assigned to one of T groups where all the teams in Group 1 pick, then all the teams in Group 2, and so on. (The coin-flipping scenario above is the case where T = 2.) What is the expected draft position of the team with the Nth-best record?

One could go the analytical route to solve this, but I wanted to take a computational, brute-force approach. This type of problem is ripe for Markov chain Monte Carlo (MCMC) methods, which I've use before in [Riddler solutions](http://www.bensoltoff.com/r/can-you-win-this-hot-new-game-show/).

The main task is to write a function that calculates the new draft position for a team given their current draft pick and potential assignment into one of `\(K\)` groups. The function I wrote is:


```r
library(tidyverse)

draft_pick_sim <- function(n_teams = 30, n_groups = 2, n_sims = 100){
  old <- 1:n_teams

  sims <- replicate(n_sims, sample(1:n_groups, n_teams, replace = T)) %>%
    as_tibble(.name_repair = "unique") %>%
    bind_cols(tibble(old)) %>%
    gather(sim, outcome, -old) %>%
    group_by(sim) %>%
    arrange(sim, outcome, old) %>%
    mutate(new = row_number())
  
  return(sims)
}
```

For each simulation, I randomly sample each team into one of `n_groups`, then calculate draft order from worst-to-first within each group and then between groups. From this I can then calculate the expected draft position for each team given their original draft order.

So given the original problem setup, the expected draft positions for each team given random assignment into one of two groups is:


```r
draft_pick_sim(n_sims = 10000) %>%
  group_by(old) %>%
  summarize(mean = mean(new)) %>%
  knitr::kable(caption = "Expected Draft Position (based on 10,000 simulations)",
               col.names = c("Original Draft Position",
                             "Expected Draft Position"))
```



Table: Table 1: Expected Draft Position (based on 10,000 simulations)

| Original Draft Position| Expected Draft Position|
|-----------------------:|-----------------------:|
|                       1|                    8.11|
|                       2|                    8.78|
|                       3|                    9.42|
|                       4|                    9.67|
|                       5|                   10.26|
|                       6|                   10.84|
|                       7|                   11.23|
|                       8|                   11.76|
|                       9|                   12.31|
|                      10|                   12.73|
|                      11|                   13.38|
|                      12|                   13.78|
|                      13|                   14.28|
|                      14|                   14.77|
|                      15|                   15.10|
|                      16|                   15.79|
|                      17|                   16.34|
|                      18|                   16.73|
|                      19|                   17.29|
|                      20|                   17.76|
|                      21|                   18.30|
|                      22|                   18.70|
|                      23|                   19.25|
|                      24|                   19.61|
|                      25|                   20.20|
|                      26|                   20.66|
|                      27|                   21.25|
|                      28|                   21.71|
|                      29|                   22.17|
|                      30|                   22.81|

The team originally with the 10th draft can expect to have the *13th pick* under this new approach.

What turned into the more complicated part was turning this function into a working Shiny app. [I encourage you to try it out](https://bensoltoff.shinyapps.io/draft_pick/), as it generalizes the problem by providing expected draft picks given `\(N\)` teams and `\(K\)` groups.

## Session Info



```r
devtools::session_info()
```

```
## ─ Session info ───────────────────────────────────────────────────────────────
##  setting  value
##  version  R version 4.2.1 (2022-06-23)
##  os       macOS Monterey 12.3
##  system   aarch64, darwin20
##  ui       X11
##  language (EN)
##  collate  en_US.UTF-8
##  ctype    en_US.UTF-8
##  tz       America/New_York
##  date     2022-11-28
##  pandoc   2.19.2 @ /Applications/RStudio.app/Contents/MacOS/quarto/bin/tools/ (via rmarkdown)
## 
## ─ Packages ───────────────────────────────────────────────────────────────────
##  package       * version date (UTC) lib source
##  assertthat      0.2.1   2019-03-21 [2] CRAN (R 4.2.0)
##  backports       1.4.1   2021-12-13 [2] CRAN (R 4.2.0)
##  blogdown        1.10    2022-05-10 [2] CRAN (R 4.2.0)
##  bookdown        0.27    2022-06-14 [2] CRAN (R 4.2.0)
##  broom           1.0.0   2022-07-01 [2] CRAN (R 4.2.0)
##  bslib           0.4.0   2022-07-16 [2] CRAN (R 4.2.0)
##  cachem          1.0.6   2021-08-19 [2] CRAN (R 4.2.0)
##  callr           3.7.1   2022-07-13 [2] CRAN (R 4.2.0)
##  cellranger      1.1.0   2016-07-27 [2] CRAN (R 4.2.0)
##  cli             3.4.1   2022-09-23 [1] CRAN (R 4.2.0)
##  codetools       0.2-18  2020-11-04 [2] CRAN (R 4.2.1)
##  colorspace      2.0-3   2022-02-21 [2] CRAN (R 4.2.0)
##  crayon          1.5.2   2022-09-29 [1] CRAN (R 4.2.0)
##  DBI             1.1.3   2022-06-18 [2] CRAN (R 4.2.0)
##  dbplyr          2.2.1   2022-06-27 [2] CRAN (R 4.2.0)
##  devtools        2.4.4   2022-07-20 [2] CRAN (R 4.2.0)
##  digest          0.6.29  2021-12-01 [2] CRAN (R 4.2.0)
##  dplyr         * 1.0.10  2022-09-01 [1] CRAN (R 4.2.0)
##  ellipsis        0.3.2   2021-04-29 [2] CRAN (R 4.2.0)
##  evaluate        0.18    2022-11-07 [1] CRAN (R 4.2.0)
##  fansi           1.0.3   2022-03-24 [2] CRAN (R 4.2.0)
##  fastmap         1.1.0   2021-01-25 [2] CRAN (R 4.2.0)
##  forcats       * 0.5.2   2022-08-19 [1] CRAN (R 4.2.0)
##  fs              1.5.2   2021-12-08 [2] CRAN (R 4.2.0)
##  gargle          1.2.0   2021-07-02 [2] CRAN (R 4.2.0)
##  generics        0.1.3   2022-07-05 [2] CRAN (R 4.2.0)
##  ggplot2       * 3.3.6   2022-05-03 [2] CRAN (R 4.2.0)
##  glue            1.6.2   2022-02-24 [2] CRAN (R 4.2.0)
##  googledrive     2.0.0   2021-07-08 [2] CRAN (R 4.2.0)
##  googlesheets4   1.0.0   2021-07-21 [2] CRAN (R 4.2.0)
##  gtable          0.3.1   2022-09-01 [1] CRAN (R 4.2.0)
##  haven           2.5.1   2022-08-22 [1] CRAN (R 4.2.0)
##  here            1.0.1   2020-12-13 [2] CRAN (R 4.2.0)
##  highr           0.9     2021-04-16 [2] CRAN (R 4.2.0)
##  hms             1.1.2   2022-08-19 [1] CRAN (R 4.2.0)
##  htmltools       0.5.3   2022-07-18 [2] CRAN (R 4.2.0)
##  htmlwidgets     1.5.4   2021-09-08 [2] CRAN (R 4.2.0)
##  httpuv          1.6.5   2022-01-05 [2] CRAN (R 4.2.0)
##  httr            1.4.3   2022-05-04 [2] CRAN (R 4.2.0)
##  jquerylib       0.1.4   2021-04-26 [2] CRAN (R 4.2.0)
##  jsonlite        1.8.0   2022-02-22 [2] CRAN (R 4.2.0)
##  knitr           1.40    2022-08-24 [1] CRAN (R 4.2.0)
##  later           1.3.0   2021-08-18 [2] CRAN (R 4.2.0)
##  lifecycle       1.0.3   2022-10-07 [1] CRAN (R 4.2.0)
##  lubridate       1.8.0   2021-10-07 [2] CRAN (R 4.2.0)
##  magrittr        2.0.3   2022-03-30 [2] CRAN (R 4.2.0)
##  memoise         2.0.1   2021-11-26 [2] CRAN (R 4.2.0)
##  mime            0.12    2021-09-28 [2] CRAN (R 4.2.0)
##  miniUI          0.1.1.1 2018-05-18 [2] CRAN (R 4.2.0)
##  modelr          0.1.8   2020-05-19 [2] CRAN (R 4.2.0)
##  munsell         0.5.0   2018-06-12 [2] CRAN (R 4.2.0)
##  pillar          1.8.1   2022-08-19 [1] CRAN (R 4.2.0)
##  pkgbuild        1.3.1   2021-12-20 [2] CRAN (R 4.2.0)
##  pkgconfig       2.0.3   2019-09-22 [2] CRAN (R 4.2.0)
##  pkgload         1.3.0   2022-06-27 [2] CRAN (R 4.2.0)
##  prettyunits     1.1.1   2020-01-24 [2] CRAN (R 4.2.0)
##  processx        3.7.0   2022-07-07 [2] CRAN (R 4.2.0)
##  profvis         0.3.7   2020-11-02 [2] CRAN (R 4.2.0)
##  promises        1.2.0.1 2021-02-11 [2] CRAN (R 4.2.0)
##  ps              1.7.1   2022-06-18 [2] CRAN (R 4.2.0)
##  purrr         * 0.3.5   2022-10-06 [1] CRAN (R 4.2.0)
##  R6              2.5.1   2021-08-19 [2] CRAN (R 4.2.0)
##  Rcpp            1.0.9   2022-07-08 [2] CRAN (R 4.2.0)
##  readr         * 2.1.3   2022-10-01 [1] CRAN (R 4.2.0)
##  readxl          1.4.0   2022-03-28 [2] CRAN (R 4.2.0)
##  remotes         2.4.2   2021-11-30 [2] CRAN (R 4.2.0)
##  reprex          2.0.2   2022-08-17 [1] CRAN (R 4.2.0)
##  rlang           1.0.6   2022-09-24 [1] CRAN (R 4.2.0)
##  rmarkdown       2.14    2022-04-25 [2] CRAN (R 4.2.0)
##  rprojroot       2.0.3   2022-04-02 [2] CRAN (R 4.2.0)
##  rstudioapi      0.13    2020-11-12 [2] CRAN (R 4.2.0)
##  rvest           1.0.2   2021-10-16 [2] CRAN (R 4.2.0)
##  sass            0.4.2   2022-07-16 [2] CRAN (R 4.2.0)
##  scales          1.2.1   2022-08-20 [1] CRAN (R 4.2.0)
##  sessioninfo     1.2.2   2021-12-06 [2] CRAN (R 4.2.0)
##  shiny           1.7.2   2022-07-19 [2] CRAN (R 4.2.0)
##  stringi         1.7.8   2022-07-11 [2] CRAN (R 4.2.0)
##  stringr       * 1.4.0   2019-02-10 [2] CRAN (R 4.2.0)
##  tibble        * 3.1.8   2022-07-22 [2] CRAN (R 4.2.0)
##  tidyr         * 1.2.0   2022-02-01 [2] CRAN (R 4.2.0)
##  tidyselect      1.2.0   2022-10-10 [1] CRAN (R 4.2.0)
##  tidyverse     * 1.3.2   2022-07-18 [2] CRAN (R 4.2.0)
##  tzdb            0.3.0   2022-03-28 [2] CRAN (R 4.2.0)
##  urlchecker      1.0.1   2021-11-30 [2] CRAN (R 4.2.0)
##  usethis         2.1.6   2022-05-25 [2] CRAN (R 4.2.0)
##  utf8            1.2.2   2021-07-24 [2] CRAN (R 4.2.0)
##  vctrs           0.5.0   2022-10-22 [1] CRAN (R 4.2.0)
##  withr           2.5.0   2022-03-03 [2] CRAN (R 4.2.0)
##  xfun            0.34    2022-10-18 [1] CRAN (R 4.2.0)
##  xml2            1.3.3   2021-11-30 [2] CRAN (R 4.2.0)
##  xtable          1.8-4   2019-04-21 [2] CRAN (R 4.2.0)
##  yaml            2.3.5   2022-02-21 [2] CRAN (R 4.2.0)
## 
##  [1] /Users/soltoffbc/Library/R/arm64/4.2/library
##  [2] /Library/Frameworks/R.framework/Versions/4.2-arm64/Resources/library
## 
## ──────────────────────────────────────────────────────────────────────────────
```
