library(tidyverse)

work_seq <- function(nth_day, n_days = 365){
  2 / (nth_day - (nth_day - 1)) * (365 - nth_day) / 365
}

tibble(
  nth_day = 1:365,
  work_complete = work_seq(nth_day = nth_day)
)

nth_day <- 1
n_days <- 365

work_completed <- vector(mode = "numeric", length = n_days)

for(i in seq_len(length.out = n_days)) {
  if(i == 1){
    work_completed[[i]] <- 2 / n_days
  } else {
    work_completed[[i]] <- 2 / (n_days - (i - 1)) * (1 - sum(work_completed[1:i - 1]))
  }

  i <- i + 1
}

tibble(
  worked = work_completed,
  worked_cum = cumsum(worked)
)
