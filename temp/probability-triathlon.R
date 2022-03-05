library(tidyverse)

# coins
coin_combos <- expand.grid(coin1 = c(F, T), coin2 = c(F, T), coin3 = c(F, T)) %>%
  rowSums() %>%
  enframe(name = ".id", value = "n") %>%
  count(n, name = "n_heads")

# dice
dice_combos <- expand.grid(
  dice1 = c(T, T, F, F, F, F),
  dice2 = c(T, T, F, F, F, F),
  dice3 = c(T, T, F, F, F, F)
) %>%
  mutate(n = dice1 + dice2 + dice3) %>%
  count(n, name = "n_dice")

# cards
card_combos <- combn(x = c(rep(x = TRUE, times = 13),
                           rep(x = FALSE, times = 39)), m = 3) %>%
  colSums() %>%
  enframe(name = "n", value = "hearts") %>%
  count(hearts, name = "n_hearts") %>%
  rename(n = hearts)

# combine all outcomes into a single data frame
outcomes <- left_join(coin_combos, dice_combos) %>%
  left_join(card_combos)

# calculate probability of each event happening within coins/dice/cards, then compare across events
outcomes %>%
  mutate(across(.cols = c(-n), .fns = ~ . / sum(.))) %>%
  mutate(prob_same = n_heads * n_dice * n_hearts) %>%
  summarize(prob_same = sum(prob_same))







