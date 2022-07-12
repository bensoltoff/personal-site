library(tidyverse)

ball_lik <- tibble(
  n_balls = seq(from = 22, to = 60, by = 2),
  lik = map_dbl(.x = n_balls, .f = ~dhyper(x = 8, m = .x / 2, n = .x / 2, k = 8 + 11))
)

max_lik <- with(ball_lik, n_balls[which.max(lik)])

ggplot(data = ball_lik, mapping = aes(x = n_balls, y = lik)) +
  geom_vline(xintercept = max_lik, linetype = 4, size = 1) +
  geom_line(linetype = 2, color = "purple") +
  geom_point(color = "purple") +
  scale_x_continuous(breaks = ball_lik$n_balls) +
  labs(
    title = "Likelihood of observed result by number of balls",
    x = "Number of balls",
    y = "Likelihood"
  ) +
  theme_minimal(base_size = 14) +
  theme(
    panel.grid.minor.x = element_blank()
  )
