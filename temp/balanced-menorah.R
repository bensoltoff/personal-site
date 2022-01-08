library(tidyverse)

tibble(
  m = 1:4,
  combinations = map(.x = m, .f = combn, x = 4, simplify = FALSE)
) %>%
  unnest_longer(combinations) %>%
  mutate(candle_sum = map_dbl(.x = combinations, .f = sum)) %>%
  count(candle_sum) %>%
  summarize(sum(n^2))
