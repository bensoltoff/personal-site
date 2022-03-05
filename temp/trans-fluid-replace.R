library(tidyverse)
library(furrr)

plan(multisession, workers = availableCores() - 2)

set.seed(123)
theme_set(theme_minimal())

pal <- "RdPu"

# function to randomly replace 1 / 12 of units with 0
replace_fluid <- function(current_fluid, amount_replaced = 1 / 12) {
  # how many units of fluid?
  fluid_units <- length(current_fluid)

  # replace appropriate prop of units with new fluid, update all other values
  c(rep(0, times = fluid_units * amount_replaced), (sample(x = current_fluid, size = fluid_units * (1 - amount_replaced))) + 1)
}

# function to simulate replacing fluid lots of times
replace_fluid_rep <- function(iter = 1000, trans_size = 12, amount_replaced = 1 / 12) {
  # generate initial fluid
  trans_fluid <- rep(12, times = trans_size)

  # placeholder for prop old
  prop_old <- vector(mode = "numeric", length = iter)

  # update fluid for each month
  for (i in 1:iter) {
    trans_fluid <- replace_fluid(trans_fluid, amount_replaced = amount_replaced)

    # what proportion is old?
    prop_old[[i]] <- sum(trans_fluid >= 12) / length(trans_fluid)
  }

  return(prop_old)
}

# simulate multiple times
n_sims <- 1000

fluid_sims <- tibble(
  trial = 1:n_sims,
  prop_old = rerun(.n = n_sims, replace_fluid_rep(trans_size = 1000))
) %>%
  unnest_longer(col = prop_old, indices_include = TRUE) %>%
  mutate(iter = prop_old_id)

fluid_sims %>%
  group_by(iter) %>%
  summarize(prop_old = mean(prop_old)) %>%
  ggplot(mapping = aes(x = iter, y = prop_old)) +
  geom_line()

fluid_sims %>%
  group_by(iter) %>%
  summarize(prop_old = mean(prop_old)) %>%
  slice_tail(n = 5)

# let's try this on different amounts replaced
set.seed(123)

fluid_sims_vary <- expand_grid(
  trial = 1:n_sims,
  amount_replaced = c(1 / 12, 1 / 10, 1 / 8, 1 / 6, 1 / 4)
) %>%
  mutate(prop_old = future_map(
    .x = amount_replaced,
    .f = ~ replace_fluid_rep(amount_replaced = .x, trans_size = 500),
    .options = furrr_options(seed = TRUE)
  )) %>%
  unnest_longer(col = prop_old, indices_include = TRUE) %>%
  mutate(iter = prop_old_id)

fluid_sims_vary %>%
  group_by(amount_replaced, iter) %>%
  summarize(prop_old = mean(prop_old)) %>%
  ungroup() %>%
  mutate(amount_replaced = factor(amount_replaced, labels = c(
    "frac(1, 12)", "frac(1, 10)",
    "frac(1, 8)", "frac(1, 6)", "frac(1, 4)"
  ))) %>%
  ggplot(mapping = aes(x = iter, y = prop_old, color = amount_replaced)) +
  geom_line(size = 1) +
  scale_color_brewer(palette = pal, labels = scales::parse_format()) +
  scale_y_continuous(labels = scales::percent) +
  labs(
    title = "Proportion of transmission fluid that is old",
    x = "Month after initial replacement",
    y = NULL,
    color = "Amount replaced\nin each month"
  )

fluid_sims_vary %>%
  mutate(amount_replaced = factor(amount_replaced, labels = c(
    "frac(1, 12)", "frac(1, 10)",
    "frac(1, 8)", "frac(1, 6)", "frac(1, 4)"
  ))) %>%
  ggplot(mapping = aes(x = iter, y = prop_old, color = amount_replaced)) +
  geom_smooth(size = 1) +
  scale_color_brewer(palette = pal, labels = scales::parse_format()) +
  scale_y_continuous(labels = scales::percent) +
  labs(
    title = "Proportion of transmission fluid that is old",
    x = "Month after initial replacement",
    y = NULL,
    color = "Amount replaced\nin each month"
  )

fluid_sims_vary %>%
  group_by(amount_replaced) %>%
  filter(iter == max(iter)) %>%
  ungroup() %>%
  mutate(amount_replaced = factor(amount_replaced, labels = c(
    "frac(1, 12)", "frac(1, 10)",
    "frac(1, 8)", "frac(1, 6)", "frac(1, 4)"
  )))%>%
  ggplot(mapping = aes(x = prop_old, color = amount_replaced)) +
  geom_density(size = 1) +
  scale_color_brewer(palette = pal, labels = scales::parse_format(), guide = guide_legend(reverse = TRUE)) +
  scale_x_continuous(labels = scales::percent) +
  labs(
    title = "Distribution of old transmission fluid",
    subtitle = glue::glue("Based on {n_sims} simulations"),
    x = "Proportion of transmission fluid that is old",
    y = NULL,
    color = "Amount replaced\nin each month"
  )
