---
title: How Many More Palindrome Dates Will You See?
author: ''
date: '2020-02-08'
slug: how-many-more-palindrome-dates-will-you-see
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



I'm currently on paternity leave and in search of quick but interesting programming challenges to stay fresh. The [latest Riddler Express](https://fivethirtyeight.com/features/how-many-more-palindrome-dates-will-you-see/) provided a quick refresher on string manipulation.

> If we write out dates in the American format of MM/DD/YYYY (i.e., the two digits of the month, followed by the two digits of the day, followed by the four digits of the year), how many more palindromic dates will there be this century?

The trick is to create a sequence of all remaining dates in the century, store them as character strings in `MM/DD/YYYY` format, then reverse each string. If the string is equal to its reverse, it's a palindrome.


```r
library(tidyverse)
library(lubridate)
library(knitr)

palindrome_usa <- tibble(
  # generate sequence of dates
  date = seq(from = mdy("02/03/2020"), to = mdy("12/31/2100"), by = "1 day"),
  # convert to character string
  date_char = date %>%
    format('%m-%d-%Y') %>%
    as.character() %>%
    # remove hyphens
    str_remove_all(pattern = "-"),
  # reverse the string and compare to original
  date_rev = stringi::stri_reverse(date_char),
  palindrome = date_char == date_rev
) %>%
  # which dates are palindromes
  filter(palindrome)
kable(palindrome_usa)
```



|date       |date_char |date_rev |palindrome |
|:----------|:---------|:--------|:----------|
|2021-12-02 |12022021  |12022021 |TRUE       |
|2030-03-02 |03022030  |03022030 |TRUE       |
|2040-04-02 |04022040  |04022040 |TRUE       |
|2050-05-02 |05022050  |05022050 |TRUE       |
|2060-06-02 |06022060  |06022060 |TRUE       |
|2070-07-02 |07022070  |07022070 |TRUE       |
|2080-08-02 |08022080  |08022080 |TRUE       |
|2090-09-02 |09022090  |09022090 |TRUE       |

Only 8 palindrome dates remaining. Out of curiosity, do any exist using the European `DD/MM/YYYY` format?


```r
palindrome_eur <- tibble(
  # generate sequence of dates
  date = seq(from = mdy("02/03/2020"), to = mdy("12/31/2100"), by = "1 day"),
  # convert to character string
  date_char = date %>%
    format('%d-%m-%Y') %>%
    as.character() %>%
    # remove hyphens
    str_remove_all(pattern = "-"),
  # reverse the string and compare to original
  date_rev = stringi::stri_reverse(date_char),
  palindrome = date_char == date_rev
) %>%
  # which dates are palindromes
  filter(palindrome)
kable(palindrome_eur)
```



|date       |date_char |date_rev |palindrome |
|:----------|:---------|:--------|:----------|
|2021-02-12 |12022021  |12022021 |TRUE       |
|2022-02-22 |22022022  |22022022 |TRUE       |
|2030-02-03 |03022030  |03022030 |TRUE       |
|2031-02-13 |13022031  |13022031 |TRUE       |
|2032-02-23 |23022032  |23022032 |TRUE       |
|2040-02-04 |04022040  |04022040 |TRUE       |
|2041-02-14 |14022041  |14022041 |TRUE       |
|2042-02-24 |24022042  |24022042 |TRUE       |
|2050-02-05 |05022050  |05022050 |TRUE       |
|2051-02-15 |15022051  |15022051 |TRUE       |
|2052-02-25 |25022052  |25022052 |TRUE       |
|2060-02-06 |06022060  |06022060 |TRUE       |
|2061-02-16 |16022061  |16022061 |TRUE       |
|2062-02-26 |26022062  |26022062 |TRUE       |
|2070-02-07 |07022070  |07022070 |TRUE       |
|2071-02-17 |17022071  |17022071 |TRUE       |
|2072-02-27 |27022072  |27022072 |TRUE       |
|2080-02-08 |08022080  |08022080 |TRUE       |
|2081-02-18 |18022081  |18022081 |TRUE       |
|2082-02-28 |28022082  |28022082 |TRUE       |
|2090-02-09 |09022090  |09022090 |TRUE       |
|2091-02-19 |19022091  |19022091 |TRUE       |
|2092-02-29 |29022092  |29022092 |TRUE       |

A lot more thanks to the reversed positioning of the month and date.

Is there any overlap between the two? That is, like `02/02/2020` and `02/02/2020`, are there any palindromic dates under both formats?


```r
semi_join(palindrome_usa, palindrome_eur, by = "date")
```

```
## # A tibble: 0 x 4
## # … with 4 variables: date <date>, date_char <chr>, date_rev <chr>,
## #   palindrome <lgl>
```

Nope.

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
##  forcats     * 0.5.0   2020-03-01 [1] CRAN (R 3.6.0)
##  fs            1.3.1   2019-05-06 [1] CRAN (R 3.6.0)
##  generics      0.0.2   2018-11-29 [1] CRAN (R 3.6.0)
##  ggplot2     * 3.2.1   2019-08-10 [1] CRAN (R 3.6.0)
##  glue          1.3.1   2019-03-12 [1] CRAN (R 3.6.0)
##  gtable        0.3.0   2019-03-25 [1] CRAN (R 3.6.0)
##  haven         2.2.0   2019-11-08 [1] CRAN (R 3.6.0)
##  here          0.1     2017-05-28 [1] CRAN (R 3.6.0)
##  highr         0.8     2019-03-20 [1] CRAN (R 3.6.0)
##  hms           0.5.3   2020-01-08 [1] CRAN (R 3.6.0)
##  htmltools     0.4.0   2019-10-04 [1] CRAN (R 3.6.0)
##  httr          1.4.1   2019-08-05 [1] CRAN (R 3.6.0)
##  jsonlite      1.6.1   2020-02-02 [1] CRAN (R 3.6.0)
##  knitr       * 1.28    2020-02-06 [1] CRAN (R 3.6.0)
##  lattice       0.20-40 2020-02-19 [1] CRAN (R 3.6.0)
##  lazyeval      0.2.2   2019-03-15 [1] CRAN (R 3.6.0)
##  lifecycle     0.1.0   2019-08-01 [1] CRAN (R 3.6.0)
##  lubridate   * 1.7.4   2018-04-11 [1] CRAN (R 3.6.0)
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
