# Description
# Output gap from QPM - X September 2026

# Preliminaries -----------------------------------------------------------
library(here)

# Functions ---------------------------------------------------------------
source(here("packages.R"))
source(here("Functions", "fx_plot.R"))

# Import -------------------------------------------------------------
output_gap_tbl <- 
  read_excel(here("Data", "Output_gap_data.xlsx")) |> 
  janitor::clean_names() |> 
  rename(date = 1) |> 
  mutate(date = as.Date(parse_date_time(date, "Yq")))


# Export ---------------------------------------------------------------
artifacts_output_gap <- list (
 output_gap_tbl = output_gap_tbl
)

write_rds(artifacts_output_gap, file = here("Outputs", "artifacts_output_gap.rds"))


