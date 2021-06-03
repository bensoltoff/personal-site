---
title: How Many More Palindrome Dates Will You See?
author: ''
date: '2020-02-08'
slug: how-many-more-palindrome-dates-will-you-see
alias: ["/post/how-many-more-palindrome-dates-will-you-see/"]
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
library(lubridate)
```

```
## 
## Attaching package: 'lubridate'
```

```
## The following objects are masked from 'package:base':
## 
##     date, intersect, setdiff, union
```

```r
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
