library(tidyverse)
library(scales)

set.seed(123)

n_sims <- 1e05
n_floors <- 10
n_goats <- 10

# play the game
goats_enter <- function(n_floors = 10, n_goats = 10){
  # initialize empty floors
  floors <- vector(mode = "logical", length = n_floors)

  # for each of the goats
  for(goat in seq_len(length.out = n_goats)){
    # get random preference of goat
    pref <- sample(x = seq_len(length.out = n_floors), size = 1)

    # if preferred floor if occupied, check the next floor(s)
    # otherwise enter the floor
    if (floors[[pref]]) {
      i <- pref + 1

      while(i <= n_floors){
        # if floor is unoccupied, then stay there
        # otherwise go to the next floor
        if(floors[[i]] == FALSE){
          floors[[i]] <- TRUE
          break
        }

        i <- i+ 1
      }
    } else {
      floors[[pref]] <- TRUE
    }
  }

  return(floors)
}

results <- tibble(
  .id = seq_len(length.out = n_sims),
  game_result = map(.x = .id, ~ goats_enter(n_floors = n_floors, n_goats = n_goats)),
  occupied_floors = map_dbl(.x = game_result, sum),
  occupied_all = occupied_floors == n_goats
)

mean(results$occupied_all)

ggplot(data = results, mapping = aes(x = .id, y = cummean(occupied_all))) +
  geom_line() +
  labs(
    title = "Can You Make Room For Goats?",
    subtitle = "Probability of occupying all ten floors",
    x = "Trial ID",
    y = "Cumulative probability"
  ) +
  scale_x_continuous(labels = label_comma()) +
  scale_y_continuous(labels = label_percent()) +
  theme_minimal()

