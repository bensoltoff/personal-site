library(tidyverse)

# d4, d6, d8
dice_3_combos <- expand_grid(
  d4 = 1:4,
  d6 = 1:6,
  d8 = 1:8
)

dice_3_combos %>%
  mutate(win = d6 > d4 & d8 > d6) %>%
  count(win)

# d4, d6, d8, d10, d12, d20
dice_6_combos <- expand_grid(
  d4 = 1:4,
  d6 = 1:6,
  d8 = 1:8,
  d10 = 1:10,
  d12 = 1:12,
  d20 = 1:20
)

dice_6_combos %>%
  mutate(win = d6 > d4 & d8 > d6 & d10 > d8 & d12 > d10 & d20 > d12) %>%
  count(win)

