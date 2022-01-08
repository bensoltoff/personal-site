library(tidyverse)
library(magrittr)
library(furrr)

# setup player data frame
players <- tibble::tribble(
  ~name, ~value, ~type,
  "pahomes", 400, "qb",
  "jallen", 350, "qb",
  "kurray", 300, "qb",
  "mcchristian", 300, "rb",
  "dook", 225, "rb",
  "denry", 200, "rb",
  "dadams", 250, "wr",
  "till", 225, "wr",
  "stiggs", 175, "wr"
)

# define draft order for fantasy teams
snake_order <- c("A", "B", "C", "C", "B", "A", "A", "B", "C")

# calculate all possible permutations
library(combinat)
draft_orders <- permn(players$name)

# throw away invalid permutations
valid_draft <- function(draft_players, draft_order = snake_order, players_df = players) {
  # replace players with positions
  draft_pos <- players$type[match(draft_players, players$name)]

  # split vector into separate teams
  draft_split <- split(x = draft_pos, f = snake_order)

  # check if each team has distinct player types
  draft_each_pos <- map_lgl(.x = draft_split, ~ n_distinct(.x) == length(.x))

  # if any of them are FALSE, invalid draft
  # reverse so TRUE means it is a valid draft order
  !any(draft_each_pos == FALSE)
}

# check all permutations
draft_orders_valid <- map_lgl(.x = draft_orders, .f = valid_draft)

# calculate fantasy scores for a given draft
fantasy_score <- function(draft_players, draft_order = snake_order, players_df = players) {
  # replace players with points
  draft_points <- players$value[match(draft_players, players$name)]

  # split vector into separate teams
  draft_split <- split(x = draft_points, f = snake_order)

  # calculate season score
  draft_score <- map_dbl(.x = draft_split, sum)
}

# apply scoring function to all valid drafts
draft_results <- map_dfr(.x = draft_orders[draft_orders_valid], .f = fantasy_score, .id = ".id")

# calculate average score for each draft position
draft_results %>%
  summarize(across(.cols = A:C, .fns = mean))

draft_results %>%
  pivot_longer(A:C, names_to = "player", values_to = "score") %>%
  ggplot(mapping = aes(x = player, y = score)) +
  geom_violin()



