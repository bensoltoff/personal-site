library(tidyverse)
library(randtests)
library(furrr)

plan(multisession, workers = availableCores() - 1)

happy <- "happy"
holidays <- "holidays"
hohohoho <- "hohohoho"

# combine all strings, identify each unique character
unique_letters <- c(happy, holidays, hohohoho) %>%
  str_c(collapse = "") %>%
  str_split(pattern = "") %>%
  nth(1) %>%
  unique()

# find all mappings of letter to digits 0:9
unique_digits <- permut(0:9, m = 9) %>%
  array_branch(margin = 1)

# function to check if digits are valid
check_digits <- function(digits_i){
  # map each letter to each digit
  digits_i <- as.character(digits_i)
  names(digits_i) <- unique_letters

  # replace each character with corresponding digit
  happy_i <- parse_number(str_replace_all(string = "happy", pattern = digits_i))
  holidays_i <- parse_number(str_replace_all(string = "holidays", pattern = digits_i))
  hohohoho_i <- parse_number(str_replace_all(string = "hohohoho", pattern = digits_i))

  # check if math expression is valid
  if(happy_i + holidays_i == hohohoho_i){
    # print digit mappings
    message(digits_i)
  }

  return(happy_i + holidays_i == hohohoho_i)
}

library(tictoc)

tic()
valid_digits <- future_map_lgl(.x = unique_digits, .f = check_digits, .progress = TRUE)
toc()


