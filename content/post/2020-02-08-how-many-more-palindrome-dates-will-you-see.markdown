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
library(lubridate)
```

```
## 
## Attaching package: 'lubridate'
```

```
## The following object is masked from 'package:base':
## 
##     date
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



