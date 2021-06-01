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
    
I'm currently teaching a [math/stats course](https://css18.github.io/) and we've recently covered a ton of different probability distributions. This problem can be defined by the [**multinomial distribution**](https://en.wikipedia.org/wiki/Multinomial_distribution), which is a generalizable form of the binomial distribution. In the original setup of the problem, `\(n=12\)`, `\(k=3\)`, and probabilities `\(p_0 = 0.2, p_1 = 0.15, p_2 = 0.6\)` for the better player winning, losing, and drawing respectively.

Based on the example [here](https://rpubs.com/JanpuHou/296336), I wrote a generalizable function to estimate the probability of win, lose, and draw for all possible outcomes for any number of `\(n\)` matches and probabilities `\(p\)`, and applied it to matches with length between 1 and 300 using the probabilities identified in the problem.


```r
library(tidyverse)
```

```
## ── Attaching packages ─────────────────────────────────────── tidyverse 1.3.1 ──
```

```
## ✓ ggplot2 3.3.3     ✓ purrr   0.3.4
## ✓ tibble  3.1.1     ✓ dplyr   1.0.6
## ✓ tidyr   1.1.3     ✓ stringr 1.4.0
## ✓ readr   1.4.0     ✓ forcats 0.5.1
```

```
## ── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
## x dplyr::filter() masks stats::filter()
## x dplyr::lag()    masks stats::lag()
```

```r
library(magrittr)
```

```
## 
## Attaching package: 'magrittr'
```

```
## The following object is masked from 'package:purrr':
## 
##     set_names
```

```
## The following object is masked from 'package:tidyr':
## 
##     extract
```

```r
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

<img src="{{< blogdown/postref >}}index_files/figure-html/plot-results-1.png" width="672" />

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

<img src="{{< blogdown/postref >}}index_files/figure-html/plot-results-2.png" width="672" />

For a standard 12 game match, the probability the better player wins is 0.7826. To achieve a 75% or better probability of success, the match length should be 11. For a 90% chance, it should be a best of 26 games match. For 99%, make that best of 251.

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
##  date     2021-05-31                  
## 
## ─ Packages ───────────────────────────────────────────────────────────────────
##  package      * version date       lib source        
##  assertthat     0.2.1   2019-03-21 [1] CRAN (R 4.0.0)
##  backports      1.2.1   2020-12-09 [1] CRAN (R 4.0.2)
##  blogdown       1.3     2021-04-14 [1] CRAN (R 4.0.2)
##  bookdown       0.22    2021-04-22 [1] CRAN (R 4.0.2)
##  broom          0.7.6   2021-04-05 [1] CRAN (R 4.0.4)
##  bslib          0.2.5   2021-05-12 [1] CRAN (R 4.0.4)
##  cachem         1.0.5   2021-05-15 [1] CRAN (R 4.0.2)
##  callr          3.7.0   2021-04-20 [1] CRAN (R 4.0.2)
##  cellranger     1.1.0   2016-07-27 [1] CRAN (R 4.0.0)
##  cli            2.5.0   2021-04-26 [1] CRAN (R 4.0.2)
##  codetools      0.2-18  2020-11-04 [1] CRAN (R 4.0.4)
##  colorspace     2.0-1   2021-05-04 [1] CRAN (R 4.0.2)
##  crayon         1.4.1   2021-02-08 [1] CRAN (R 4.0.2)
##  DBI            1.1.1   2021-01-15 [1] CRAN (R 4.0.2)
##  dbplyr         2.1.1   2021-04-06 [1] CRAN (R 4.0.4)
##  desc           1.3.0   2021-03-05 [1] CRAN (R 4.0.2)
##  devtools       2.4.1   2021-05-05 [1] CRAN (R 4.0.2)
##  digest         0.6.27  2020-10-24 [1] CRAN (R 4.0.2)
##  dplyr        * 1.0.6   2021-05-05 [1] CRAN (R 4.0.2)
##  ellipsis       0.3.2   2021-04-29 [1] CRAN (R 4.0.2)
##  evaluate       0.14    2019-05-28 [1] CRAN (R 4.0.0)
##  fansi          0.4.2   2021-01-15 [1] CRAN (R 4.0.2)
##  farver         2.1.0   2021-02-28 [1] CRAN (R 4.0.2)
##  fastmap        1.1.0   2021-01-25 [1] CRAN (R 4.0.2)
##  forcats      * 0.5.1   2021-01-27 [1] CRAN (R 4.0.2)
##  fs             1.5.0   2020-07-31 [1] CRAN (R 4.0.2)
##  generics       0.1.0   2020-10-31 [1] CRAN (R 4.0.2)
##  ggplot2      * 3.3.3   2020-12-30 [1] CRAN (R 4.0.2)
##  glue           1.4.2   2020-08-27 [1] CRAN (R 4.0.2)
##  gtable         0.3.0   2019-03-25 [1] CRAN (R 4.0.0)
##  haven          2.4.1   2021-04-23 [1] CRAN (R 4.0.2)
##  here           1.0.1   2020-12-13 [1] CRAN (R 4.0.2)
##  highr          0.9     2021-04-16 [1] CRAN (R 4.0.2)
##  hms            1.1.0   2021-05-17 [1] CRAN (R 4.0.4)
##  htmltools      0.5.1.1 2021-01-22 [1] CRAN (R 4.0.2)
##  httr           1.4.2   2020-07-20 [1] CRAN (R 4.0.2)
##  jquerylib      0.1.4   2021-04-26 [1] CRAN (R 4.0.2)
##  jsonlite       1.7.2   2020-12-09 [1] CRAN (R 4.0.2)
##  knitr          1.33    2021-04-24 [1] CRAN (R 4.0.2)
##  labeling       0.4.2   2020-10-20 [1] CRAN (R 4.0.2)
##  lifecycle      1.0.0   2021-02-15 [1] CRAN (R 4.0.2)
##  lubridate      1.7.10  2021-02-26 [1] CRAN (R 4.0.2)
##  magrittr     * 2.0.1   2020-11-17 [1] CRAN (R 4.0.2)
##  memoise        2.0.0   2021-01-26 [1] CRAN (R 4.0.2)
##  modelr         0.1.8   2020-05-19 [1] CRAN (R 4.0.0)
##  munsell        0.5.0   2018-06-12 [1] CRAN (R 4.0.0)
##  pillar         1.6.1   2021-05-16 [1] CRAN (R 4.0.4)
##  pkgbuild       1.2.0   2020-12-15 [1] CRAN (R 4.0.2)
##  pkgconfig      2.0.3   2019-09-22 [1] CRAN (R 4.0.0)
##  pkgload        1.2.1   2021-04-06 [1] CRAN (R 4.0.2)
##  prettyunits    1.1.1   2020-01-24 [1] CRAN (R 4.0.0)
##  processx       3.5.2   2021-04-30 [1] CRAN (R 4.0.2)
##  ps             1.6.0   2021-02-28 [1] CRAN (R 4.0.2)
##  purrr        * 0.3.4   2020-04-17 [1] CRAN (R 4.0.0)
##  R6             2.5.0   2020-10-28 [1] CRAN (R 4.0.2)
##  RColorBrewer   1.1-2   2014-12-07 [1] CRAN (R 4.0.0)
##  Rcpp           1.0.6   2021-01-15 [1] CRAN (R 4.0.2)
##  readr        * 1.4.0   2020-10-05 [1] CRAN (R 4.0.2)
##  readxl         1.3.1   2019-03-13 [1] CRAN (R 4.0.0)
##  remotes        2.3.0   2021-04-01 [1] CRAN (R 4.0.2)
##  reprex         2.0.0   2021-04-02 [1] CRAN (R 4.0.2)
##  rlang          0.4.11  2021-04-30 [1] CRAN (R 4.0.2)
##  rmarkdown      2.8     2021-05-07 [1] CRAN (R 4.0.2)
##  rprojroot      2.0.2   2020-11-15 [1] CRAN (R 4.0.2)
##  rstudioapi     0.13    2020-11-12 [1] CRAN (R 4.0.2)
##  rvest          1.0.0   2021-03-09 [1] CRAN (R 4.0.2)
##  sass           0.4.0   2021-05-12 [1] CRAN (R 4.0.2)
##  scales         1.1.1   2020-05-11 [1] CRAN (R 4.0.0)
##  sessioninfo    1.1.1   2018-11-05 [1] CRAN (R 4.0.0)
##  stringi        1.6.1   2021-05-10 [1] CRAN (R 4.0.2)
##  stringr      * 1.4.0   2019-02-10 [1] CRAN (R 4.0.0)
##  testthat       3.0.2   2021-02-14 [1] CRAN (R 4.0.2)
##  tibble       * 3.1.1   2021-04-18 [1] CRAN (R 4.0.2)
##  tidyr        * 1.1.3   2021-03-03 [1] CRAN (R 4.0.2)
##  tidyselect     1.1.1   2021-04-30 [1] CRAN (R 4.0.2)
##  tidyverse    * 1.3.1   2021-04-15 [1] CRAN (R 4.0.2)
##  usethis        2.0.1   2021-02-10 [1] CRAN (R 4.0.2)
##  utf8           1.2.1   2021-03-12 [1] CRAN (R 4.0.2)
##  vctrs          0.3.8   2021-04-29 [1] CRAN (R 4.0.2)
##  withr          2.4.2   2021-04-18 [1] CRAN (R 4.0.2)
##  xfun           0.23    2021-05-15 [1] CRAN (R 4.0.2)
##  xml2           1.3.2   2020-04-23 [1] CRAN (R 4.0.0)
##  yaml           2.2.1   2020-02-01 [1] CRAN (R 4.0.0)
## 
## [1] /Library/Frameworks/R.framework/Versions/4.0/Resources/library
```
