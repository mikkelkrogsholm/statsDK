## ---- warning=FALSE, message=FALSE---------------------------------------
library(statsDK); library(tidyverse); library(stringr)

tables <- retrieve_tables()

glimpse(tables)

## ------------------------------------------------------------------------
tables_long <- tables %>%
  unnest(variables)

## ------------------------------------------------------------------------

marriage_tables <- tables_long %>%
  filter(str_detect(tables_long$variables, "marriage"))

glimpse(marriage_tables)


## ------------------------------------------------------------------------
viedag_meta <- retrieve_metadata("VIEDAG")

glimpse(viedag_meta)

## ------------------------------------------------------------------------
variables <- get_variables(viedag_meta)

glimpse(variables)

## ------------------------------------------------------------------------
variable_overview <- variables %>% 
  group_by(param) %>%
  slice(c(1, round(n()/2), n())) %>%
  ungroup()

variable_overview

## ------------------------------------------------------------------------
VIEDAG <- retrieve_data("VIEDAG", Tid = "*", VDAG = "TOT", VIMDR = "006,012")

## ------------------------------------------------------------------------
glimpse(VIEDAG)

## ---- fig.width=4*1.618, fig.height=4------------------------------------

VIEDAG$time <- as.numeric(VIEDAG$time)

ggplot(VIEDAG) +
  geom_line(aes(x = time, value, group = `month of the marriage`)) +
  annotate("text", x = 2016.1, y = c(3396, 1721), label = c("June", "December"),
           hjust = 0) +
  annotate("point", x = 2016, y = c(3396, 1721)) +
  xlim(2007, 2017) +
  labs(y = "Total marriages for the given month", x = "Years") +
  theme_minimal()

