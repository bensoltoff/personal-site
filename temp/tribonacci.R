library(tidyverse)

tribonacci <- function(a, b, c, max_val = 2023){
  # create empty vector to store values
  seq_vals <- c(a, b, c)

  # set i to 3
  i <- 3

  complete <- FALSE

  while(!complete){
    # sum the past three values, append to end of vector
    seq_vals[[i + 1]] <- sum(seq_vals[(i-2):i])

    # if new value is greater than max_val, exit loop
    if(seq_vals[[i + 1]] >= max_val) break

    i <- i + 1
  }

  return(seq_vals)
}

tribonacci(1, 2, 3)

expand_grid(
  a = 1:10,
  b = 1:10,
  c = 1:10
) |>
  rowwise() |>
  filter(a <= b, b <= c) |>
  ungroup() |>
  mutate(trib_seq = pmap(.l = list(a, b, c), .f = tribonacci),
         val_exists = map_lgl(.x = trib_seq, .f = ~ 2023 %in% .x)) %>%
  filter(val_exists)
