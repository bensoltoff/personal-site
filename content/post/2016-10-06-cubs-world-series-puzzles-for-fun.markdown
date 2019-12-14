---
title: Cubs World Series Puzzles (For Fun)
author: ''
date: '2016-10-06'
slug: cubs-world-series-puzzles-for-fun
categories:
  - r
tags:
  - r
  - riddler
subtitle: "Expanding on the Riddler's Problem"
summary: ''
authors: []
featured: no
image:
  caption: ''
  focal_point: ''
  preview_only: no
projects: []
---





[This week's Riddler Express from FiveThirtyEight](http://fivethirtyeight.com/features/cubs-world-series-puzzles-for-fun-and-profit/):

> The best team in baseball this year, the Chicago Cubs, have clinched their playoff spot and will play their first playoff game a week from today. The Cubs’ road to the World Series title consists of a best-of-five series followed by two best-of-seven series. How many unique strings of wins and losses could the Cubs assemble if they make their way through the playoffs and win their first championship title since 1908? (For example, one possible string would be WWWWWWWWWWW — three straight sweeps. Another would be WWWWWWWLLLWWWW — two sweeps plus a dramatic World Series comeback.)2

A quick and dirty computational approach to calculating all the unique winning combinations.


```r
# get the tidyverse libraries (mainly purrr)
library(tidyverse)
```

```
## ── Attaching packages ─────────────────────────────────────────────────────────────────── tidyverse 1.3.0 ──
```

```
## ✓ ggplot2 3.2.1     ✓ purrr   0.3.3
## ✓ tibble  2.1.3     ✓ dplyr   0.8.3
## ✓ tidyr   1.0.0     ✓ stringr 1.4.0
## ✓ readr   1.3.1     ✓ forcats 0.4.0
```

```
## ── Conflicts ────────────────────────────────────────────────────────────────────── tidyverse_conflicts() ──
## x dplyr::filter() masks stats::filter()
## x dplyr::lag()    masks stats::lag()
```

```r
set.seed(123)

# number of simulations to run
n_sims <- 10000

# function to calculate sum of unique series winning combinations
calc_win_combos <- function(games = 5, n_sims = 10){
  series_win <- n_sims %>%
    rerun(sample(c(1, 0), games, replace = TRUE)) %>%
    unlist %>%
    matrix(ncol = games, byrow = TRUE) %>%
    unique %>%
    rowSums %>%
    .[] >= ceiling(games / 2)
  
  return(sum(series_win))
}

# get total number of unique winning combos for best-of-five
# and best-of-seven series
wins_5 <- calc_win_combos(n_sims = n_sims)
wins_7 <- calc_win_combos(games = 7, n_sims = n_sims)

# multiply together (NLDS, NLCS, WS)
wins_5 * wins_7 * wins_7
```

```
## [1] 65536
```

There's a lot of ways the Cubs could win the World Series. Of course, [history isn't exactly on their side](https://en.wikipedia.org/wiki/Curse_of_the_Billy_Goat).[^1]

[^1]: But as a newly Chicagoan, I won't mind hopping on the bandwagon.
