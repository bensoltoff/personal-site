# https://fivethirtyeight.com/features/when-will-the-fall-colors-peak/

library(tidyverse)

# generate data frame of L and N
# N is all integers less than 400
# L must always be less than or equal to N
expand_grid(
  N = 1:399,
  L = 1:399
  ) %>%
  filter(L <= N) %>%
  mutate(
    # calculate average solar year length
    solar_year = (L * 366 + (N - L) * 365) / N,
    # calculate difference from Gregorian average
    diff = abs(365.24217 - solar_year)
    ) %>%
  # find N and L with smallest diff
  arrange(diff)
