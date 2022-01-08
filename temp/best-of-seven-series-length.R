library(tidyverse)

# generate all possible outcomes
crossing(g1 = 0:1,
         g2 = 0:1,
         g3 = 0:1,
         g4 = 0:1,
         g5 = 0:1,
         g6 = 0:1,
         g7 = 0:1) %>%
  mutate(.id = row_number()) %>%
  # pivot to store one row per game
  pivot_longer(cols = -.id, names_to = "game", values_to = "winner") %>%
  mutate(game = parse_number(game)) %>%
  # calculate cumulative sum of victories for both teams
  group_by(.id) %>%
  mutate(t1_wins = cumsum(winner == 1),
         t0_wins = cumsum(winner == 0)) %>%
  # determine the number of victories for the team
  # leading in the series
  rowwise() %>%
  mutate(leader_wins = max(t1_wins, t0_wins)) %>%
  # find the first row where the leader has four wins
  group_by(.id) %>%
  filter(leader_wins == 4) %>%
  # only keep first appearance
  slice_head(n = 1) %>%
  ungroup() %>%
  summarize(mean_games = mean(game),
            median_games = median(game))

