library(tidyverse)

set.seed(123)

# function to simulate finding start and end of leaf transition
leaf_transition <- function() {
  # find start time of transition
  trans_start <- runif(n = 1, min = 0, max = 1)

  # find end time
  trans_end <- runif(n = 1, min = trans_start, max = 1)

  return(c(trans_start, trans_end))
}

# rerun N times, store as a matrix
n_sims <- 1e04
leaf_sims <- rerun(.n = n_sims, leaf_transition()) %>%
  unlist() %>%
  matrix(nrow = n_sims, byrow = TRUE)

# intervals to check at
check_intervals <- seq(from = 0, to = 1, by = 0.001)
map2(
  .x = leaf_sims[, 1],
  .y = leaf_sims[, 2],
  .f = between,
  x = check_intervals
) %>%
  unlist() %>%
  matrix(nrow = length(check_intervals), byrow = TRUE) %>%
  rowSums() %>%
  enframe(
    name = ".id",
    value = "in_transition"
  ) %>%
  mutate(in_transition_pct = in_transition / n_sims) %>%
  ggplot(mapping = aes(x = in_transition_pct)) +
  geom_histogram(bins = 100)
