---
title: A Modified Draft Pick Selection Order
author: ''
date: '2016-09-20'
slug: a-modified-draft-pick-selection-order
aliases: ["/r/expected-draft-pick/"]
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

The main task is to write a function that calculates the new draft position for a team given their current draft pick and potential assignment into one of $K$ groups. The function I wrote is:


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



| Original Draft Position| Expected Draft Position|
|-----------------------:|-----------------------:|
|                       1|                    8.14|
|                       2|                    8.77|
|                       3|                    9.36|
|                       4|                    9.79|
|                       5|                   10.22|
|                       6|                   10.69|
|                       7|                   11.37|
|                       8|                   11.59|
|                       9|                   12.07|
|                      10|                   12.63|
|                      11|                   13.35|
|                      12|                   13.72|
|                      13|                   14.33|
|                      14|                   14.47|
|                      15|                   15.26|
|                      16|                   15.85|
|                      17|                   16.32|
|                      18|                   16.76|
|                      19|                   17.24|
|                      20|                   17.81|
|                      21|                   18.30|
|                      22|                   18.73|
|                      23|                   19.29|
|                      24|                   19.80|
|                      25|                   20.28|
|                      26|                   20.73|
|                      27|                   21.24|
|                      28|                   21.81|
|                      29|                   22.36|
|                      30|                   22.74|

The team originally with the 10th draft can expect to have the *13th pick* under this new approach.

What turned into the more complicated part was turning this function into a working Shiny app. [I encourage you to try it out](https://bensoltoff.shinyapps.io/draft_pick/), as it generalizes the problem by providing expected draft picks given $N$ teams and $K$ groups.

## Session Info



```r
devtools::session_info()
```

```
## ─ Session info ───────────────────────────────────────────────────────────────
##  setting  value                       
##  version  R version 3.6.1 (2019-07-05)
##  os       macOS Catalina 10.15.3      
##  system   x86_64, darwin15.6.0        
##  ui       X11                         
##  language (EN)                        
##  collate  en_US.UTF-8                 
##  ctype    en_US.UTF-8                 
##  tz       America/Chicago             
##  date     2020-03-09                  
## 
## ─ Packages ───────────────────────────────────────────────────────────────────
##  package     * version date       lib source        
##  assertthat    0.2.1   2019-03-21 [1] CRAN (R 3.6.0)
##  backports     1.1.5   2019-10-02 [1] CRAN (R 3.6.0)
##  blogdown      0.17.1  2020-02-13 [1] local         
##  bookdown      0.17    2020-01-11 [1] CRAN (R 3.6.0)
##  callr         3.4.2   2020-02-12 [1] CRAN (R 3.6.1)
##  cli           2.0.2   2020-02-28 [1] CRAN (R 3.6.0)
##  crayon        1.3.4   2017-09-16 [1] CRAN (R 3.6.0)
##  desc          1.2.0   2018-05-01 [1] CRAN (R 3.6.0)
##  devtools      2.2.2   2020-02-17 [1] CRAN (R 3.6.0)
##  digest        0.6.25  2020-02-23 [1] CRAN (R 3.6.0)
##  ellipsis      0.3.0   2019-09-20 [1] CRAN (R 3.6.0)
##  evaluate      0.14    2019-05-28 [1] CRAN (R 3.6.0)
##  fansi         0.4.1   2020-01-08 [1] CRAN (R 3.6.0)
##  fs            1.3.1   2019-05-06 [1] CRAN (R 3.6.0)
##  glue          1.3.1   2019-03-12 [1] CRAN (R 3.6.0)
##  here          0.1     2017-05-28 [1] CRAN (R 3.6.0)
##  htmltools     0.4.0   2019-10-04 [1] CRAN (R 3.6.0)
##  knitr         1.28    2020-02-06 [1] CRAN (R 3.6.0)
##  magrittr      1.5     2014-11-22 [1] CRAN (R 3.6.0)
##  memoise       1.1.0   2017-04-21 [1] CRAN (R 3.6.0)
##  pkgbuild      1.0.6   2019-10-09 [1] CRAN (R 3.6.0)
##  pkgload       1.0.2   2018-10-29 [1] CRAN (R 3.6.0)
##  prettyunits   1.1.1   2020-01-24 [1] CRAN (R 3.6.0)
##  processx      3.4.2   2020-02-09 [1] CRAN (R 3.6.0)
##  ps            1.3.2   2020-02-13 [1] CRAN (R 3.6.0)
##  R6            2.4.1   2019-11-12 [1] CRAN (R 3.6.0)
##  Rcpp          1.0.3   2019-11-08 [1] CRAN (R 3.6.0)
##  remotes       2.1.1   2020-02-15 [1] CRAN (R 3.6.0)
##  rlang         0.4.5   2020-03-01 [1] CRAN (R 3.6.0)
##  rmarkdown     2.1     2020-01-20 [1] CRAN (R 3.6.0)
##  rprojroot     1.3-2   2018-01-03 [1] CRAN (R 3.6.0)
##  sessioninfo   1.1.1   2018-11-05 [1] CRAN (R 3.6.0)
##  stringi       1.4.6   2020-02-17 [1] CRAN (R 3.6.0)
##  stringr       1.4.0   2019-02-10 [1] CRAN (R 3.6.0)
##  testthat      2.3.1   2019-12-01 [1] CRAN (R 3.6.0)
##  usethis       1.5.1   2019-07-04 [1] CRAN (R 3.6.0)
##  withr         2.1.2   2018-03-15 [1] CRAN (R 3.6.0)
##  xfun          0.12    2020-01-13 [1] CRAN (R 3.6.0)
##  yaml          2.2.1   2020-02-01 [1] CRAN (R 3.6.0)
## 
## [1] /Library/Frameworks/R.framework/Versions/3.6/Resources/library
```
