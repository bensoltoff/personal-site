# https://fivethirtyeight.com/features/a-riddle-that-will-make-you-scream/

library(tidyverse)

# prob of correct choice - .6
# number of guesses - 3
# prob that at least two are correct?

# exact prob
sum(dbinom(x = 0:3, size = 3, prob = .6)[3:4])

# simulated values
set.seed(123)
rbinom(n = 10000, size = 3, prob = .6) %>%
  enframe() %>%
  count(value) %>%
  summarize(pct = n / sum(n))
