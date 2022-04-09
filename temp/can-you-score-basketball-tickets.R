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
  mutate(combos_sum = map_dbl(.x = combos_poss, .f = sum))
poss_outcomes

# all possible combinations of 4 number choices
poss_combos <- combn(2:12, m = 4) %>%
  array_branch(margin = 2) %>%
  enframe(name = ".id", value = "roll_choices")

poss_combos %>%
  # calculate how often each combination of choices wins
  mutate(num_victory = map_dbl(.x = roll_choices, .f = ~ poss_outcomes %>%
                                 filter(combos_sum %in% .x) %>%
                                 ungroup() %>%
                                 distinct(.id) %>%
                                 nrow()
  )) %>%
  arrange(-num_victory)
