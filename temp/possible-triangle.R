library(tidyverse)

possible_triangle <- function(coins) {
  coins <- sort(coins)
  coins[[1]] + coins[[2]] > coins[[3]]
}

coins <- c(1, 5, 10, 25)

tibble(
  coin1 = coins,
  coin2 = coins,
  coin3 = coins
) %>%
  expand(coin1, coin2, coin3) %>%
  rowwise() %>%
  mutate(tri_poss = possible_triangle(c(coin1, coin2, coin3))) %>%
  ungroup() %>%
  count(tri_poss)
