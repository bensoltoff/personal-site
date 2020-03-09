---
title: Winning the World Chess Championship
author: ''
date: '2018-11-16'
slug: winning-the-world-chess-championship
aliases: ["/r/world-chess-championship/"]
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



[This week's Riddler Express from FiveThirtyEight](https://fivethirtyeight.com/features/the-riddler-just-had-to-go-and-reinvent-beer-pong/):

> The World Chess Championship is underway. It is a 12-game match between the world’s top two grandmasters. Many chess fans feel that 12 games is far too short for a biennial world championship match, allowing too much variance.
    Say one of the players is better than his opponent to the degree that he wins 20 percent of all games, loses 15 percent of games and that 65 percent of games are drawn. Wins at this match are worth 1 point, draws a half-point for each player, and losses 0 points. In a 12-game match, the first player to 6.5 points wins.
    What are the chances the better player wins a 12-game match? How many games would a match have to be in order to give the better player a 75 chance of winning the match outright? A 90 percent chance? A 99 percent chance?
    
I'm currently teaching a [math/stats course](https://css18.github.io/) and we've recently covered a ton of different probability distributions. This problem can be defined by the [**multinomial distribution**](https://en.wikipedia.org/wiki/Multinomial_distribution), which is a generalizable form of the binomial distribution. In the original setup of the problem, $n=12$, $k=3$, and probabilities $p_0 = 0.2, p_1 = 0.15, p_2 = 0.6$ for the better player winning, losing, and drawing respectively.

Based on the example [here](https://rpubs.com/JanpuHou/296336), I wrote a generalizable function to estimate the probability of win, lose, and draw for all possible outcomes for any number of $n$ matches and probabilities $p$, and applied it to matches with length between 1 and 300 using the probabilities identified in the problem.


```r
library(tidyverse)
library(magrittr)

theme_set(theme_minimal(base_size = 18))
```


```r
chess_outcomes <- function(n_matches, prob){
  # define all possibilities
  X <- expand.grid(n = 0:n_matches,
                   k = 0:3) %>%
    as.matrix %>%
    t
  X <- X[, colSums(X) <= n_matches]
  X <- rbind(X, n_matches:n_matches - colSums(X))
  dimnames(X) <- list(c("win", "lose", "draw"), NULL)
  
  # calculate probabilities of each outcome
  X_prob <- array_branch(X, margin = 2) %>%
    map_dbl(dmultinom, prob = prob)
  
  # combine together
  outcomes <- X %>%
    t %>%
    as_tibble %>%
    mutate(points = win * 1 + lose * 0 + draw * .5,
           prob = X_prob)
  
  return(outcomes)
}
```


```r
# iterate over a varying number of matches
varying_matches <- tibble(n_matches = 1:300) %>%
  mutate(outcomes = map(n_matches, chess_outcomes, prob = c(0.2, 0.15, 0.65)),
         prob_win = map2_dbl(outcomes, n_matches, ~ mean(.x$points > (.y / 2))),
         prob_draw = map2_dbl(outcomes, n_matches, ~ mean(.x$points == (.y / 2))),
         prob_loss = map2_dbl(outcomes, n_matches, ~ mean(.x$points < (.y / 2))))
```


```r
ggplot(varying_matches, aes(n_matches, prob_win)) +
  geom_line() +
  scale_y_continuous(labels = scales::percent) +
  labs(title = "World chess championship",
       x = "Maximum number of matches",
       y = "Probability of victory")
```

<img src="/post/2018-11-16-winning-the-world-chess-championship_files/figure-html/plot-results-1.png" width="672" />

```r
varying_matches %>%
  gather(outcome, prob, starts_with("prob")) %>%
  mutate(outcome = str_remove(outcome, "prob_"),
         outcome = str_to_title(outcome)) %>%
  ggplot(aes(n_matches, prob, color = outcome)) +
  geom_line() +
  scale_y_continuous(labels = scales::percent) +
  scale_color_brewer(type = "qual") +
  labs(title = "World chess championship",
       x = "Maximum number of matches",
       y = "Probability",
       color = NULL) +
  theme(legend.position = "bottom")
```

<img src="/post/2018-11-16-winning-the-world-chess-championship_files/figure-html/plot-results-2.png" width="672" />

For a standard 12 game match, the probability the better player wins is 0.7826. To achieve a 75% or better probability of success, the match length should be 11. For a 90% chance, it should be a best of 26 games match. For 99%, make that best of 251.

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
##  package      * version date       lib source        
##  assertthat     0.2.1   2019-03-21 [1] CRAN (R 3.6.0)
##  backports      1.1.5   2019-10-02 [1] CRAN (R 3.6.0)
##  blogdown       0.17.1  2020-02-13 [1] local         
##  bookdown       0.17    2020-01-11 [1] CRAN (R 3.6.0)
##  broom          0.5.5   2020-02-29 [1] CRAN (R 3.6.0)
##  callr          3.4.2   2020-02-12 [1] CRAN (R 3.6.1)
##  cellranger     1.1.0   2016-07-27 [1] CRAN (R 3.6.0)
##  cli            2.0.2   2020-02-28 [1] CRAN (R 3.6.0)
##  codetools      0.2-16  2018-12-24 [1] CRAN (R 3.6.1)
##  colorspace     1.4-1   2019-03-18 [1] CRAN (R 3.6.0)
##  crayon         1.3.4   2017-09-16 [1] CRAN (R 3.6.0)
##  DBI            1.1.0   2019-12-15 [1] CRAN (R 3.6.0)
##  dbplyr         1.4.2   2019-06-17 [1] CRAN (R 3.6.0)
##  desc           1.2.0   2018-05-01 [1] CRAN (R 3.6.0)
##  devtools       2.2.2   2020-02-17 [1] CRAN (R 3.6.0)
##  digest         0.6.25  2020-02-23 [1] CRAN (R 3.6.0)
##  dplyr        * 0.8.4   2020-01-31 [1] CRAN (R 3.6.0)
##  ellipsis       0.3.0   2019-09-20 [1] CRAN (R 3.6.0)
##  evaluate       0.14    2019-05-28 [1] CRAN (R 3.6.0)
##  fansi          0.4.1   2020-01-08 [1] CRAN (R 3.6.0)
##  farver         2.0.3   2020-01-16 [1] CRAN (R 3.6.0)
##  forcats      * 0.5.0   2020-03-01 [1] CRAN (R 3.6.0)
##  fs             1.3.1   2019-05-06 [1] CRAN (R 3.6.0)
##  generics       0.0.2   2018-11-29 [1] CRAN (R 3.6.0)
##  ggplot2      * 3.2.1   2019-08-10 [1] CRAN (R 3.6.0)
##  glue           1.3.1   2019-03-12 [1] CRAN (R 3.6.0)
##  gtable         0.3.0   2019-03-25 [1] CRAN (R 3.6.0)
##  haven          2.2.0   2019-11-08 [1] CRAN (R 3.6.0)
##  here           0.1     2017-05-28 [1] CRAN (R 3.6.0)
##  hms            0.5.3   2020-01-08 [1] CRAN (R 3.6.0)
##  htmltools      0.4.0   2019-10-04 [1] CRAN (R 3.6.0)
##  httr           1.4.1   2019-08-05 [1] CRAN (R 3.6.0)
##  jsonlite       1.6.1   2020-02-02 [1] CRAN (R 3.6.0)
##  knitr          1.28    2020-02-06 [1] CRAN (R 3.6.0)
##  labeling       0.3     2014-08-23 [1] CRAN (R 3.6.0)
##  lattice        0.20-40 2020-02-19 [1] CRAN (R 3.6.0)
##  lazyeval       0.2.2   2019-03-15 [1] CRAN (R 3.6.0)
##  lifecycle      0.1.0   2019-08-01 [1] CRAN (R 3.6.0)
##  lubridate      1.7.4   2018-04-11 [1] CRAN (R 3.6.0)
##  magrittr     * 1.5     2014-11-22 [1] CRAN (R 3.6.0)
##  memoise        1.1.0   2017-04-21 [1] CRAN (R 3.6.0)
##  modelr         0.1.6   2020-02-22 [1] CRAN (R 3.6.0)
##  munsell        0.5.0   2018-06-12 [1] CRAN (R 3.6.0)
##  nlme           3.1-144 2020-02-06 [1] CRAN (R 3.6.0)
##  pillar         1.4.3   2019-12-20 [1] CRAN (R 3.6.0)
##  pkgbuild       1.0.6   2019-10-09 [1] CRAN (R 3.6.0)
##  pkgconfig      2.0.3   2019-09-22 [1] CRAN (R 3.6.0)
##  pkgload        1.0.2   2018-10-29 [1] CRAN (R 3.6.0)
##  prettyunits    1.1.1   2020-01-24 [1] CRAN (R 3.6.0)
##  processx       3.4.2   2020-02-09 [1] CRAN (R 3.6.0)
##  ps             1.3.2   2020-02-13 [1] CRAN (R 3.6.0)
##  purrr        * 0.3.3   2019-10-18 [1] CRAN (R 3.6.0)
##  R6             2.4.1   2019-11-12 [1] CRAN (R 3.6.0)
##  RColorBrewer   1.1-2   2014-12-07 [1] CRAN (R 3.6.0)
##  Rcpp           1.0.3   2019-11-08 [1] CRAN (R 3.6.0)
##  readr        * 1.3.1   2018-12-21 [1] CRAN (R 3.6.0)
##  readxl         1.3.1   2019-03-13 [1] CRAN (R 3.6.0)
##  remotes        2.1.1   2020-02-15 [1] CRAN (R 3.6.0)
##  reprex         0.3.0   2019-05-16 [1] CRAN (R 3.6.0)
##  rlang          0.4.5   2020-03-01 [1] CRAN (R 3.6.0)
##  rmarkdown      2.1     2020-01-20 [1] CRAN (R 3.6.0)
##  rprojroot      1.3-2   2018-01-03 [1] CRAN (R 3.6.0)
##  rstudioapi     0.11    2020-02-07 [1] CRAN (R 3.6.0)
##  rvest          0.3.5   2019-11-08 [1] CRAN (R 3.6.0)
##  scales         1.1.0   2019-11-18 [1] CRAN (R 3.6.0)
##  sessioninfo    1.1.1   2018-11-05 [1] CRAN (R 3.6.0)
##  stringi        1.4.6   2020-02-17 [1] CRAN (R 3.6.0)
##  stringr      * 1.4.0   2019-02-10 [1] CRAN (R 3.6.0)
##  testthat       2.3.1   2019-12-01 [1] CRAN (R 3.6.0)
##  tibble       * 2.1.3   2019-06-06 [1] CRAN (R 3.6.0)
##  tidyr        * 1.0.2   2020-01-24 [1] CRAN (R 3.6.0)
##  tidyselect     1.0.0   2020-01-27 [1] CRAN (R 3.6.0)
##  tidyverse    * 1.3.0   2019-11-21 [1] CRAN (R 3.6.0)
##  usethis        1.5.1   2019-07-04 [1] CRAN (R 3.6.0)
##  vctrs          0.2.3   2020-02-20 [1] CRAN (R 3.6.0)
##  withr          2.1.2   2018-03-15 [1] CRAN (R 3.6.0)
##  xfun           0.12    2020-01-13 [1] CRAN (R 3.6.0)
##  xml2           1.2.2   2019-08-09 [1] CRAN (R 3.6.0)
##  yaml           2.2.1   2020-02-01 [1] CRAN (R 3.6.0)
## 
## [1] /Library/Frameworks/R.framework/Versions/3.6/Resources/library
```
