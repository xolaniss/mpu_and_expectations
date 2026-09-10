# Description
# model data - X Aug 2026
# Preliminaries -----------------------------------------------------------
library(here)

# Functions ---------------------------------------------------------------
source(here("packages.R"))
source(here("Functions", "fx_plot.R"))

# Import -------------------------------------------------------------
model_data_tbl <- 
  fs::dir_ls(here("Outputs")) |> 
  # Exclude this script's own output so reruns don't feed on themselves
  purrr::discard(~str_detect(.x, "model_data.")) |> 
  map(~read_rds(.x) |> pluck(1)) |> 
  # Standardise the join key - the rand vol artifact uses "quarter"
  # instead of "date"
  map(~rename(.x, date = any_of("quarter"))) |> 
  reduce(full_join, by = "date") |> 
  mutate(date = as.Date(date))

# Export ---------------------------------------------------------------
artifacts_model_data <- list (
 model_data_tbl = model_data_tbl
)

write_rds(artifacts_model_data, file = here("Outputs", "artifacts_model_data.rds"))

write_csv(model_data_tbl, here("Outputs", "model_data.csv"))

