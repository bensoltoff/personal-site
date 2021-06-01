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

One could go the analytical route to solve this

{{< tweet 778056486593454080 >}}

But I wanted to take a computational, brute-force approach. This type of problem is ripe for Markov chain Monte Carlo (MCMC) methods, which I've use before in [Riddler solutions](http://www.bensoltoff.com/r/can-you-win-this-hot-new-game-show/).

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
|                       1|                    8.24|
|                       2|                    8.81|
|                       3|                    9.25|
|                       4|                    9.80|
|                       5|                   10.21|
|                       6|                   10.69|
|                       7|                   11.24|
|                       8|                   11.80|
|                       9|                   12.24|
|                      10|                   12.76|
|                      11|                   13.17|
|                      12|                   13.65|
|                      13|                   14.32|
|                      14|                   14.78|
|                      15|                   15.22|
|                      16|                   15.75|
|                      17|                   16.16|
|                      18|                   16.74|
|                      19|                   17.28|
|                      20|                   17.86|
|                      21|                   18.13|
|                      22|                   18.75|
|                      23|                   19.35|
|                      24|                   19.76|
|                      25|                   20.27|
|                      26|                   20.68|
|                      27|                   21.22|
|                      28|                   21.82|
|                      29|                   22.25|
|                      30|                   22.78|

The team originally with the 10th draft can expect to have the *13th pick* under this new approach.

What turned into the more complicated part was turning this function into a working Shiny app. [I encourage you to try it out](https://bensoltoff.shinyapps.io/draft_pick/), as it generalizes the problem by providing expected draft picks given `\(N\)` teams and `\(K\)` groups.

## Session Info



```r
devtools::session_info()
```

```
## ─ Session info ───────────────────────────────────────────────────────────────
##  setting  value                       
##  version  R version 4.0.4 (2021-02-15)
##  os       macOS Big Sur 10.16         
##  system   x86_64, darwin17.0          
##  ui       X11                         
##  language (EN)                        
##  collate  en_US.UTF-8                 
##  ctype    en_US.UTF-8                 
##  tz       America/Chicago             
##  date     2021-06-01                  
## 
## ─ Packages ───────────────────────────────────────────────────────────────────
##  package     * version date       lib source        
##  blogdown      1.3     2021-04-14 [1] CRAN (R 4.0.2)
##  bookdown      0.22    2021-04-22 [1] CRAN (R 4.0.2)
##  bslib         0.2.5   2021-05-12 [1] CRAN (R 4.0.4)
##  cachem        1.0.5   2021-05-15 [1] CRAN (R 4.0.2)
##  callr         3.7.0   2021-04-20 [1] CRAN (R 4.0.2)
##  cli           2.5.0   2021-04-26 [1] CRAN (R 4.0.2)
##  crayon        1.4.1   2021-02-08 [1] CRAN (R 4.0.2)
##  desc          1.3.0   2021-03-05 [1] CRAN (R 4.0.2)
##  devtools      2.4.1   2021-05-05 [1] CRAN (R 4.0.2)
##  digest        0.6.27  2020-10-24 [1] CRAN (R 4.0.2)
##  ellipsis      0.3.2   2021-04-29 [1] CRAN (R 4.0.2)
##  evaluate      0.14    2019-05-28 [1] CRAN (R 4.0.0)
##  fastmap       1.1.0   2021-01-25 [1] CRAN (R 4.0.2)
##  fs            1.5.0   2020-07-31 [1] CRAN (R 4.0.2)
##  glue          1.4.2   2020-08-27 [1] CRAN (R 4.0.2)
##  here          1.0.1   2020-12-13 [1] CRAN (R 4.0.2)
##  htmltools     0.5.1.1 2021-01-22 [1] CRAN (R 4.0.2)
##  jquerylib     0.1.4   2021-04-26 [1] CRAN (R 4.0.2)
##  jsonlite      1.7.2   2020-12-09 [1] CRAN (R 4.0.2)
##  knitr         1.33    2021-04-24 [1] CRAN (R 4.0.2)
##  lifecycle     1.0.0   2021-02-15 [1] CRAN (R 4.0.2)
##  magrittr      2.0.1   2020-11-17 [1] CRAN (R 4.0.2)
##  memoise       2.0.0   2021-01-26 [1] CRAN (R 4.0.2)
##  pkgbuild      1.2.0   2020-12-15 [1] CRAN (R 4.0.2)
##  pkgload       1.2.1   2021-04-06 [1] CRAN (R 4.0.2)
##  prettyunits   1.1.1   2020-01-24 [1] CRAN (R 4.0.0)
##  processx      3.5.2   2021-04-30 [1] CRAN (R 4.0.2)
##  ps            1.6.0   2021-02-28 [1] CRAN (R 4.0.2)
##  purrr         0.3.4   2020-04-17 [1] CRAN (R 4.0.0)
##  R6            2.5.0   2020-10-28 [1] CRAN (R 4.0.2)
##  remotes       2.3.0   2021-04-01 [1] CRAN (R 4.0.2)
##  rlang         0.4.11  2021-04-30 [1] CRAN (R 4.0.2)
##  rmarkdown     2.8     2021-05-07 [1] CRAN (R 4.0.2)
##  rprojroot     2.0.2   2020-11-15 [1] CRAN (R 4.0.2)
##  sass          0.4.0   2021-05-12 [1] CRAN (R 4.0.2)
##  sessioninfo   1.1.1   2018-11-05 [1] CRAN (R 4.0.0)
##  stringi       1.6.1   2021-05-10 [1] CRAN (R 4.0.2)
##  stringr       1.4.0   2019-02-10 [1] CRAN (R 4.0.0)
##  testthat      3.0.2   2021-02-14 [1] CRAN (R 4.0.2)
##  usethis       2.0.1   2021-02-10 [1] CRAN (R 4.0.2)
##  withr         2.4.2   2021-04-18 [1] CRAN (R 4.0.2)
##  xfun          0.23    2021-05-15 [1] CRAN (R 4.0.2)
##  yaml          2.2.1   2020-02-01 [1] CRAN (R 4.0.0)
## 
## [1] /Library/Frameworks/R.framework/Versions/4.0/Resources/library
```
