library(tidyverse)

# number of simulations
n_sim <- 1e3

# generate set of three coins
samp_coins <- function(coins = c(1, 5, 10, 25)) {
  sample(x = coins, size = 3, replace = TRUE)
}


# check to see if sum of two smaller values is greater than largest value
possible_triangle <- function(coins) {
  coins <- sort(coins)
  coins[[1]] + coins[[2]] > coins[[3]]
}

# simulate a bunch of times
set.seed(123)
coins_sim <- tibble(
  coins = rerun(samp_coins(), .n = n_sim),
  valid_triangle = map_lgl(.x = coins, possible_triangle)
)

# proportion of sims where a valid triangle exists
mean(coins_sim$valid_triangle)
