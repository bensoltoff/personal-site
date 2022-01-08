---
title: More Menorah Math!
author: Benjamin Soltoff
date: '2021-12-15'
slug: more-menorah-math
categories:
  - R
tags:
  - r
  - riddler
subtitle: ''
draft: no
series: ~
layout: single
---



This week's [Riddler Express](https://fivethirtyeight.com/features/can-you-slice-the-ice/) deals with some menorah math that provides a good application for combinatorics:

> Tonight marks the sixth night of Hanukkah, which means it's time for some more Menorah Math!
> 
> I have a most peculiar menorah. Like most menorahs, it has nine total candles — a central candle, called the shamash, four to the left of the shamash and another four to the right. But unlike most menorahs, the eight candles on either side of the shamash are numbered. The two candles adjacent to the shamash are both "1," the next two candles out from the shamash are "2," the next pair are "3," and the outermost pair are "4."
> 
> The shamash is always lit. How many ways are there to light the remaining eight candles so that sums on either side of the menorah are "balanced"? (For example, one such way is to light candles 1 and 4 on one side and candles 2 and 3 on the other side. In this case, the sums on both sides are 5, so the menorah is balanced.)

In this problem, we need to identify all the possible combinations of lighting each of the four sets of candles such that each side has the same number of candles lit.

We could do this by hand, but R has the handy `combn()` function for generating all combinations of a set of elements. For example, if we wanted all combinations of choosing three candles we could write:


```r
library(tidyverse)
```


```r
combn(x = 4, m = 3)
```

```
##      [,1] [,2] [,3] [,4]
## [1,]    1    1    1    2
## [2,]    2    2    3    3
## [3,]    3    4    4    4
```

In this problem we could choose `\([0, 1, 2, 3, 4]\)` candles from each side. So we need to find all possible combinations for each of those quantities. `combn()` can only be used with a single `m` value. To vectorize the operation, I leveraged the `map()` function from [`purrr`](https://purrr.tidyverse.org/).


```r
tibble(
  m = 0:4,
  combinations = map(.x = m, .f = combn, x = 4, simplify = FALSE)
)
```

```
## # A tibble: 5 × 2
##       m combinations
##   <int> <list>      
## 1     0 <list [1]>  
## 2     1 <list [4]>  
## 3     2 <list [6]>  
## 4     3 <list [4]>  
## 5     4 <list [1]>
```

Since the number of possible combinations varies for each `m`, we need to expand the `combinations` column so the data frame is one row per combination. `tidyr::unnest_longer()` serves that purpose.


```r
tibble(
  m = 0:4,
  combinations = map(.x = m, .f = combn, x = 4, simplify = FALSE)
) %>%
  unnest_longer(combinations)
```

```
## # A tibble: 16 × 2
##        m combinations
##    <int> <list>      
##  1     0 <int [0]>   
##  2     1 <int [1]>   
##  3     1 <int [1]>   
##  4     1 <int [1]>   
##  5     1 <int [1]>   
##  6     2 <int [2]>   
##  7     2 <int [2]>   
##  8     2 <int [2]>   
##  9     2 <int [2]>   
## 10     2 <int [2]>   
## 11     2 <int [2]>   
## 12     3 <int [3]>   
## 13     3 <int [3]>   
## 14     3 <int [3]>   
## 15     3 <int [3]>   
## 16     4 <int [4]>
```

Now the `combinations` column is a list-column, where every element is a numeric vector identifying which candles are lit in this scenario. To calculate the sum of the candles based on their position, we need to add together the index values stored within these vectors.


```r
tibble(
  m = 0:4,
  combinations = map(.x = m, .f = combn, x = 4, simplify = FALSE)
) %>%
  unnest_longer(combinations) %>%
  mutate(candle_sum = map_dbl(.x = combinations, .f = sum))
```

```
## # A tibble: 16 × 3
##        m combinations candle_sum
##    <int> <list>            <dbl>
##  1     0 <int [0]>             0
##  2     1 <int [1]>             1
##  3     1 <int [1]>             2
##  4     1 <int [1]>             3
##  5     1 <int [1]>             4
##  6     2 <int [2]>             3
##  7     2 <int [2]>             4
##  8     2 <int [2]>             5
##  9     2 <int [2]>             5
## 10     2 <int [2]>             6
## 11     2 <int [2]>             7
## 12     3 <int [3]>             6
## 13     3 <int [3]>             7
## 14     3 <int [3]>             8
## 15     3 <int [3]>             9
## 16     4 <int [4]>            10
```

From here, we calculate how many times each unique sum appears in the data frame.


```r
tibble(
  m = 0:4,
  combinations = map(.x = m, .f = combn, x = 4, simplify = FALSE)
) %>%
  unnest_longer(combinations) %>%
  mutate(candle_sum = map_dbl(.x = combinations, .f = sum)) %>%
  count(candle_sum)
```

```
## # A tibble: 11 × 2
##    candle_sum     n
##         <dbl> <int>
##  1          0     1
##  2          1     1
##  3          2     1
##  4          3     2
##  5          4     2
##  6          5     2
##  7          6     2
##  8          7     2
##  9          8     1
## 10          9     1
## 11         10     1
```

For the rows with `n` values of 1, there is only one possible way to achieve that sum. However for rows with `n` values of `2`, there are two possible combinations that achieve that sum. For example, candles 1 and 2 can be lit to achieve a sum of 3, as well as simply lighting candle 3. Since either side could be lit using these combinations, that actually leaves four ways (i.e. `\(2^2\)`) to achieve that equal weighting. So all we need to do is sum up the square of each value in the `n` column to determine the total number of ways to light each side such that they are "balanced".


```r
tibble(
  m = 0:4,
  combinations = map(.x = m, .f = combn, x = 4, simplify = FALSE)
) %>%
  unnest_longer(combinations) %>%
  mutate(candle_sum = map_dbl(.x = combinations, .f = sum)) %>%
  count(candle_sum) %>%
  summarize(sum(n^2))
```

```
## # A tibble: 1 × 1
##   `sum(n^2)`
##        <dbl>
## 1         26
```



The result is 26 possible combinations.






