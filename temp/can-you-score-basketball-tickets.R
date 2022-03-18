library(tidyverse)

# generate all possible combinations of dice rolls
poss_outcomes <- expand_grid(
  d1 = 1:6,
  d2 = 1:6,
  d3 = 1:6,
  d4 = 1:6
) %>%
  # convert to a data frame with all four values stored as a single numeric vector for each roll
  as.matrix() %>%
  array_branch(margin = 1) %>%
  enframe(name = ".id", value = "roll_outcomes") %>%
  # calculate all possible combinations from the four rolls
  mutate(combos_poss = map(.x = roll_outcomes, .f = combn, m = 2, simplify = FALSE)) %>%
  unnest_longer(col = combos_poss) %>%
  # calculate the sum of all possible two-dice combos
  mutate(combos_sum = map_dbl(.x = combos_poss, .f = sum)) %>%
  # count how often each sum can be obtained
  count(combos_sum)
poss_outcomes

# 6, 7, 8, and either 5/9 occur most frequently
# what percentage of four dice rolls capture these four outcomes?
sum(poss_outcomes$n[4:7]) / sum(poss_outcomes$n)
