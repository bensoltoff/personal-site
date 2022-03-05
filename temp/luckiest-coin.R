library(tidyverse)

set.seed(123)

n_sims <- 1e04

tibble(
  me = runif(n = n_sims, min = 0.1, max = 0.8),
  you = runif(n = n_sims, min = 0, max = 1),
  win = me > you
) %>%
  mutate(.id = row_number(),
         win_pct = cummean(win)) %>%
  ggplot(mapping = aes(x = .id, y = win_pct)) +
  geom_line() +
  scale_x_continuous(labels = scales::comma) +
  scale_y_continuous(labels = scales::percent)


sim_flips <- function(n_coins = 1e03){
  while(n_coins > 1){
    # simulate coin flips and count how many are TRUE
    n_coins <- rbinom(n = 1, size = n_coins, prob = 0.5)
  }

  return(n_coins)
}

map_dbl(.x = 1:n_sims, ~ sim_flips(n_coins = 1e06)) %>%
  mean()

# will it run efficiently?
microbenchmark::microbenchmark(sim_flips(n_coins = 1e06))

microbenchmark::microbenchmark(
  rbernoulli = rbernoulli(n = 1, p = 0.5),
  rbinom = rbinom(n = 1, size = 1, prob = 0.5)
) %>%
  autoplot()

microbenchmark::microbenchmark(
  n_1 = rbinom(n = 1, size = n_coins, prob = 0.5),
  n_coins = sum(rbinom(n = n_coins, size = 1, p = 0.5))
) %>%
  autoplot()







