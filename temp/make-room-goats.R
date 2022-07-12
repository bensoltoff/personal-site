library(tidyverse)

prices <- seq(from = 0.01, to = 7.11, by = 0.01)

# first two combos
prod_two <- expand_grid(n1 = prices, n2 = prices) %>%
  # check that sum is less than 7.11
  filter(n1 + n2 < 7.11) %>%
  # only keep first permutation
  filter(n1 <= n2)

# first three combos
prod_three <- expand_grid(prod_two, n3 = prices) %>%
  # check sum is less than 7.11
  filter(n1 + n2  + n3 < 7.11) %>%
  filter(n1 <= n2, n2 <= n3)

# figure out what value needs to be for fourth price to sum
# to 7.11
prod_four <- prod_three %>%
  mutate(n4 = 7.11 - n1 - n2 - n3)

# only keep rows where product of four prices is 7.11
prod_four %>%
  filter(n1 * n2 * n3 * n4 == 7.11)
