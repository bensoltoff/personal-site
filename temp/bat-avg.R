library(tidyverse)

# build table of hit/at-bat combinations
bat_avg_possible <- tibble(
  # number of games played (cannot have bat avg > 1.000)
  games_played = seq(from = 1, to = 1000),
  # calculate number of at-bats
  at_bats = games_played * 4,
  # generate all possible numbers of hits within given N games
  hits_possible = map(.x = at_bats, ~ seq(from = 0, to = .x))
) %>%
  # unnest all combinations and calculate batting average
  unnest_longer(col = hits_possible) %>%
  mutate(bat_avg = hits_possible / at_bats)

# which games_played has a matching bat_avg
games_match_bat_avg <- bat_avg_possible %>%
  # multiply bat_avg by 1000 and round to eliminate extra decimals
  mutate(bat_avg_n = round(bat_avg * 1000)) %>%
  # keep observations with same number of games played and batting average
  filter(games_played == bat_avg_n) %>%
  # just keep distinct games_played
  distinct(games_played)

# which games_played have no match
games_match_bat_avg_not <- distinct(.data = bat_avg_possible, games_played) %>%
  anti_join(games_match_bat_avg)
arrange(.data = games_match_bat_avg_not, -games_played)


