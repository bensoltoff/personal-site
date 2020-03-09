---
title: How Good Are You At Guess Who?
author: ''
date: '2020-03-08'
slug: how-good-are-you-at-guess-who
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



The most recent [Riddler Express](https://fivethirtyeight.com/features/how-good-are-you-at-guess-who/) gave me an opportunity to refresh some base R notation, as well as combine it with a technique I learned while reading Hadley Wickham's [Advanced R](https://adv-r.hadley.nz/). The challenge is:

> A local cafe has board games on a shelf, designed to keep kids (and some adults) entertained while they wait on their food. One of the games is a tic-tac-toe board, which comes with nine pieces that you and your opponent can place: five Xs and four Os.
> 
> When I took my two-year-old with me, he wasn’t particularly interested in the game itself, but rather in the placement of the pieces.
> 
> If he randomly places all nine pieces in the nine slots on the tic-tac-toe board (with one piece in each slot), what’s the probability that X wins? That is, what’s the probability that there will be at least one occurrence of three Xs in a row at the same time there are no occurrences of three Os in a row?
    
My first thought was that a tic-tac-toe board can be represented as a matrix. If any of the columns or rows or diagonals of the matrix contain three Xs while simultaneously not containing any Os, X wins.

I don't typically work with matrix structures in R (more often my work involves data frames), but this proved to be a nice refresher. My first approach was to simulate $N$ games of tic-tac-toe by random sampling from the set of Xs and Os. Then I remembered teaching permutations in [a statistics class last year](https://css18.github.io/probability.html#counting). Why not consider all possible outcomes and calculate the winner? There are

$$\frac{n!}{(n - k)!}$$

possible outcomes, where we choose $k$ objects from a set of $n$ objects. In this instance, we consider

$$\frac{9!}{(9-9)!} = \frac{9!}{0!}$$

where by definition $0! = 1$. So we have 362,880 possible outcomes. We can generate all those possible outcomes using `gtools::permutations()`. In order to use this function, each value in the vector to permute must be unique. So I represent each value uniquely, then after I generate all possible permutations represent the Xs as $+1$ and the Os as $-1$.


```r
library(tidyverse)
```

```
## ── Attaching packages ──────────────────────────────────────────────────────────────────── tidyverse 1.3.0 ──
```

```
## ✓ ggplot2 3.2.1     ✓ purrr   0.3.3
## ✓ tibble  2.1.3     ✓ dplyr   0.8.4
## ✓ tidyr   1.0.2     ✓ stringr 1.4.0
## ✓ readr   1.3.1     ✓ forcats 0.5.0
```

```
## ── Conflicts ─────────────────────────────────────────────────────────────────────── tidyverse_conflicts() ──
## x dplyr::filter() masks stats::filter()
## x dplyr::lag()    masks stats::lag()
```

```r
set.seed(123)

theme_set(theme_minimal(base_size = 18))
```


```r
pieces <- c(rep(1, times = 5), rep(-1, times = 4))
all_outcomes <- gtools::permutations(n = length(pieces), r = length(pieces), v = seq_along(pieces))
head(all_outcomes)
```

```
##      [,1] [,2] [,3] [,4] [,5] [,6] [,7] [,8] [,9]
## [1,]    1    2    3    4    5    6    7    8    9
## [2,]    1    2    3    4    5    6    7    9    8
## [3,]    1    2    3    4    5    6    8    7    9
## [4,]    1    2    3    4    5    6    8    9    7
## [5,]    1    2    3    4    5    6    9    7    8
## [6,]    1    2    3    4    5    6    9    8    7
```

```r
# 1:5 = X, 6:9 = O
all_outcomes[all_outcomes <= 5] <- 1
all_outcomes[all_outcomes > 5] <- -1
head(all_outcomes)
```

```
##      [,1] [,2] [,3] [,4] [,5] [,6] [,7] [,8] [,9]
## [1,]    1    1    1    1    1   -1   -1   -1   -1
## [2,]    1    1    1    1    1   -1   -1   -1   -1
## [3,]    1    1    1    1    1   -1   -1   -1   -1
## [4,]    1    1    1    1    1   -1   -1   -1   -1
## [5,]    1    1    1    1    1   -1   -1   -1   -1
## [6,]    1    1    1    1    1   -1   -1   -1   -1
```

Next I wrote a function that takes a single permutation as its input, turns it into a matrix, and checks to see if there are three Xs in any row, column, or diagonal. Since `diag()` only returns the diagonal of a matrix and I also need to evaluate the diagonal running from bottom to top, I use the `rotate()` function[^SO] to turn the game board 90 degrees - this allows me to use the `diag()` function to obtain the same results.


```r
# function to rotate a matrix 90 degrees to check the other diagonal
rotate <- function(x) t(apply(x, 2, rev))

# function to evaluate the outcome of the game
tic_tac_toe <- function(game_board, print_board = FALSE) {
  # generate random assortment
  game_board <- matrix(data = game_board, nrow = 3)
  if (print_board) print(game_board)

  # check if any row or colsums or diag or inverse diag are 3
  # if TRUE, also confirm none are -3
  if (3 %in% colSums(game_board) ||
    3 %in% rowSums(game_board) ||
    sum(diag(game_board)) == 3 ||
    sum(diag(rotate(game_board))) == 3) {
    if (-3 %in% colSums(game_board) ||
      -3 %in% rowSums(game_board) ||
      sum(diag(game_board)) == -3 ||
      sum(diag(rotate(game_board))) == -3) {
      return("Draw")
    }

    return("X wins")
  } else if (-3 %in% colSums(game_board) ||
    -3 %in% rowSums(game_board) ||
    sum(diag(game_board)) == -3 ||
    sum(diag(rotate(game_board))) == -3) {
    return("O wins")
  } else {
    return("Draw")
  }
}

tic_tac_toe(all_outcomes[1, ], print_board = TRUE) # test the function
```

```
##      [,1] [,2] [,3]
## [1,]    1    1   -1
## [2,]    1    1   -1
## [3,]    1   -1   -1
```

```
## [1] "Draw"
```

Now that I know the function works, I need to apply it to all possible outcomes. Since `all_outcomes` is structured as a matrix, an `apply()` function would be appropriate here. The problem is I have not used `apply()` in years, and I am biased towards `purrr::map()` functions. Typically `map()` cannot be used on a matrix input. However, [`purrr` includes a handy function called `array_branch()`](https://github.com/tidyverse/purrr/issues/341#issuecomment-353959893) which converts a matrix to a list object that can then be mapped over.


```r
all_outcomes <- tibble(
  outcome = array_branch(all_outcomes, 1),
  result = map_chr(outcome, tic_tac_toe)
)
all_outcomes
```

```
## # A tibble: 362,880 x 2
##    outcome   result
##    <list>    <chr> 
##  1 <dbl [9]> Draw  
##  2 <dbl [9]> Draw  
##  3 <dbl [9]> Draw  
##  4 <dbl [9]> Draw  
##  5 <dbl [9]> Draw  
##  6 <dbl [9]> Draw  
##  7 <dbl [9]> Draw  
##  8 <dbl [9]> Draw  
##  9 <dbl [9]> Draw  
## 10 <dbl [9]> Draw  
## # … with 362,870 more rows
```

So what are the results? What is the probability X wins?


```r
all_outcomes_sum <- all_outcomes %>%
  count(result) %>%
  mutate(prop = n / sum(n))

ggplot(
  data = all_outcomes_sum,
  mapping = aes(x = fct_reorder(result, -prop), y = prop)
) +
  geom_col() +
  scale_y_continuous(labels = scales::percent) +
  labs(
    title = "Probability of each outcome in tic-tac-toe",
    x = NULL,
    y = NULL
  )
```

<img src="/post/2020-03-08-how-good-are-you-at-guess-who_files/figure-html/results-1.png" width="672" />

Overall, X wins approximately 49.2% of all possible matches. A draw is the next most likely outcome, whereas O's probability of success is a measly 9.5%. First-mover advantage is strong here. Of course, we also know the only winning move is not to play.

{{< youtube NHWjlCaIrQo >}}

[^SO]: Hat tip to [Stack Overflow](https://stackoverflow.com/a/16497058)

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
##  broom         0.5.5   2020-02-29 [1] CRAN (R 3.6.0)
##  callr         3.4.2   2020-02-12 [1] CRAN (R 3.6.1)
##  cellranger    1.1.0   2016-07-27 [1] CRAN (R 3.6.0)
##  cli           2.0.2   2020-02-28 [1] CRAN (R 3.6.0)
##  codetools     0.2-16  2018-12-24 [1] CRAN (R 3.6.1)
##  colorspace    1.4-1   2019-03-18 [1] CRAN (R 3.6.0)
##  crayon        1.3.4   2017-09-16 [1] CRAN (R 3.6.0)
##  DBI           1.1.0   2019-12-15 [1] CRAN (R 3.6.0)
##  dbplyr        1.4.2   2019-06-17 [1] CRAN (R 3.6.0)
##  desc          1.2.0   2018-05-01 [1] CRAN (R 3.6.0)
##  devtools      2.2.2   2020-02-17 [1] CRAN (R 3.6.0)
##  digest        0.6.25  2020-02-23 [1] CRAN (R 3.6.0)
##  dplyr       * 0.8.4   2020-01-31 [1] CRAN (R 3.6.0)
##  ellipsis      0.3.0   2019-09-20 [1] CRAN (R 3.6.0)
##  evaluate      0.14    2019-05-28 [1] CRAN (R 3.6.0)
##  fansi         0.4.1   2020-01-08 [1] CRAN (R 3.6.0)
##  farver        2.0.3   2020-01-16 [1] CRAN (R 3.6.0)
##  forcats     * 0.5.0   2020-03-01 [1] CRAN (R 3.6.0)
##  fs            1.3.1   2019-05-06 [1] CRAN (R 3.6.0)
##  generics      0.0.2   2018-11-29 [1] CRAN (R 3.6.0)
##  ggplot2     * 3.2.1   2019-08-10 [1] CRAN (R 3.6.0)
##  glue          1.3.1   2019-03-12 [1] CRAN (R 3.6.0)
##  gtable        0.3.0   2019-03-25 [1] CRAN (R 3.6.0)
##  gtools        3.8.1   2018-06-26 [1] CRAN (R 3.6.0)
##  haven         2.2.0   2019-11-08 [1] CRAN (R 3.6.0)
##  here          0.1     2017-05-28 [1] CRAN (R 3.6.0)
##  hms           0.5.3   2020-01-08 [1] CRAN (R 3.6.0)
##  htmltools     0.4.0   2019-10-04 [1] CRAN (R 3.6.0)
##  httr          1.4.1   2019-08-05 [1] CRAN (R 3.6.0)
##  jsonlite      1.6.1   2020-02-02 [1] CRAN (R 3.6.0)
##  knitr         1.28    2020-02-06 [1] CRAN (R 3.6.0)
##  labeling      0.3     2014-08-23 [1] CRAN (R 3.6.0)
##  lattice       0.20-40 2020-02-19 [1] CRAN (R 3.6.0)
##  lazyeval      0.2.2   2019-03-15 [1] CRAN (R 3.6.0)
##  lifecycle     0.1.0   2019-08-01 [1] CRAN (R 3.6.0)
##  lubridate     1.7.4   2018-04-11 [1] CRAN (R 3.6.0)
##  magrittr      1.5     2014-11-22 [1] CRAN (R 3.6.0)
##  memoise       1.1.0   2017-04-21 [1] CRAN (R 3.6.0)
##  modelr        0.1.6   2020-02-22 [1] CRAN (R 3.6.0)
##  munsell       0.5.0   2018-06-12 [1] CRAN (R 3.6.0)
##  nlme          3.1-144 2020-02-06 [1] CRAN (R 3.6.0)
##  pillar        1.4.3   2019-12-20 [1] CRAN (R 3.6.0)
##  pkgbuild      1.0.6   2019-10-09 [1] CRAN (R 3.6.0)
##  pkgconfig     2.0.3   2019-09-22 [1] CRAN (R 3.6.0)
##  pkgload       1.0.2   2018-10-29 [1] CRAN (R 3.6.0)
##  prettyunits   1.1.1   2020-01-24 [1] CRAN (R 3.6.0)
##  processx      3.4.2   2020-02-09 [1] CRAN (R 3.6.0)
##  ps            1.3.2   2020-02-13 [1] CRAN (R 3.6.0)
##  purrr       * 0.3.3   2019-10-18 [1] CRAN (R 3.6.0)
##  R6            2.4.1   2019-11-12 [1] CRAN (R 3.6.0)
##  Rcpp          1.0.3   2019-11-08 [1] CRAN (R 3.6.0)
##  readr       * 1.3.1   2018-12-21 [1] CRAN (R 3.6.0)
##  readxl        1.3.1   2019-03-13 [1] CRAN (R 3.6.0)
##  remotes       2.1.1   2020-02-15 [1] CRAN (R 3.6.0)
##  reprex        0.3.0   2019-05-16 [1] CRAN (R 3.6.0)
##  rlang         0.4.5   2020-03-01 [1] CRAN (R 3.6.0)
##  rmarkdown     2.1     2020-01-20 [1] CRAN (R 3.6.0)
##  rprojroot     1.3-2   2018-01-03 [1] CRAN (R 3.6.0)
##  rstudioapi    0.11    2020-02-07 [1] CRAN (R 3.6.0)
##  rvest         0.3.5   2019-11-08 [1] CRAN (R 3.6.0)
##  scales        1.1.0   2019-11-18 [1] CRAN (R 3.6.0)
##  sessioninfo   1.1.1   2018-11-05 [1] CRAN (R 3.6.0)
##  stringi       1.4.6   2020-02-17 [1] CRAN (R 3.6.0)
##  stringr     * 1.4.0   2019-02-10 [1] CRAN (R 3.6.0)
##  testthat      2.3.1   2019-12-01 [1] CRAN (R 3.6.0)
##  tibble      * 2.1.3   2019-06-06 [1] CRAN (R 3.6.0)
##  tidyr       * 1.0.2   2020-01-24 [1] CRAN (R 3.6.0)
##  tidyselect    1.0.0   2020-01-27 [1] CRAN (R 3.6.0)
##  tidyverse   * 1.3.0   2019-11-21 [1] CRAN (R 3.6.0)
##  usethis       1.5.1   2019-07-04 [1] CRAN (R 3.6.0)
##  utf8          1.1.4   2018-05-24 [1] CRAN (R 3.6.0)
##  vctrs         0.2.3   2020-02-20 [1] CRAN (R 3.6.0)
##  withr         2.1.2   2018-03-15 [1] CRAN (R 3.6.0)
##  xfun          0.12    2020-01-13 [1] CRAN (R 3.6.0)
##  xml2          1.2.2   2019-08-09 [1] CRAN (R 3.6.0)
##  yaml          2.2.1   2020-02-01 [1] CRAN (R 3.6.0)
## 
## [1] /Library/Frameworks/R.framework/Versions/3.6/Resources/library
```

