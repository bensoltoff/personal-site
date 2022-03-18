library(tidyverse)
library(here)

# input data
jacob_flips <- tribble(
  ~ trial, ~ flip, ~ num,
  "Attempt 1", "Heads", 6,
  "Attempt 1", "Tails", 4,
  "Attempt 2", "Heads", 7,
  "Attempt 2", "Tails", 3
) %>%
  mutate(flip = fct_rev(flip))
jacob_flips

# draw a bar graph
ggplot(data = jacob_flips, mapping = aes(x = num, y = flip)) +
  geom_col() +
  facet_wrap(vars(trial), ncol = 1) +
  labs(
    title = "Different ways of flips",
    x = "Number of flips",
    y = NULL,
    caption = "Data made by Jacob Soltoff"
  ) +
  theme_classic(base_size = 12)
ggsave(filename = here("static", "img", "jacob-flips-1.png"), width = 9, height = 6)

# draw a color bar chart
ggplot(data = jacob_flips, mapping = aes(x = 1, y = num, fill = flip)) +
  geom_col() +
  scale_y_continuous(breaks = 0:10) +
  scale_fill_manual(values = c("blue", "yellow"), guide = guide_legend(reverse = TRUE)) +
  facet_wrap(vars(trial), ncol = 1) +
  coord_flip() +
  labs(
    title = "Different ways of flips",
    x = NULL,
    y = "Number of flips",
    fill = NULL,
    caption = "Data made by Jacob Soltoff"
  ) +
  theme_classic(base_size = 16) +
  theme(legend.position = "bottom",
        axis.text.y = element_blank(),
        axis.ticks.y = element_blank())
