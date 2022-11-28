# https://fivethirtyeight.com/features/can-you-fold-all-your-socks/

library(tidyverse)
library(lubridate)
library(furrr)

plan(multisession, workers = 4)

# all digits from 0-9
digits <- 0:9

# find all permutations
digits_perm <- combinat::permn(x = digits)

# convert permutations to character vector of collapsed strings
digits_strings <- future_map_chr(.x = digits_perm, .f = str_c, collapse = "")

# convert strings to date-time objects
digits_dates <- parse_date_time(x = digits_strings, orders = "IMSY")
digits_dates <- digits_dates[!is.na(digits_dates)]
digits_dates <- sort(digits_dates)

# which is the first one after now?
digits_dates[digits_dates > now()][[1]]
