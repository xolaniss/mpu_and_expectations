# Description

# Preliminaries -----------------------------------------------------------
library(here)

# Functions ---------------------------------------------------------------
source(here("packages.R"))
source(here("Functions", "fx_plot.R"))

clean_up <- function(data){
  data |>
    janitor::clean_names() |> 
    rename(
    date = period_date
    ) |>
    # Horizon labels come as e.g. "T0 (current year)"; recode to the
    # description in snake_case for use in column names.
    # T0 = current year, T1 = next year, T2 = year after next,
    # 5a = 5-year ahead
    mutate(
      horizon = str_extract(horizon, "(?<=\\()[^)]+"),
      horizon = str_replace_all(horizon, "[- ]", "_")
    ) |> 
    select(date, horizon, sd)
}

# Import -------------------------------------------------------------
business_dispersion_tbl <- read_excel(here("Data", "BER_Business_Dispersion.xlsx"), sheet = 2)
finance_dispersion_tbl <- read_excel(here("Data", "BER_Finance_Dispersion.xlsx"), sheet = 2)
labour_dispersion_tbl <- read_excel(here("Data", "BER_Labour_Dispersion.xlsx"), sheet = 2)

combined_tbl <- 
  list(
  "business" = business_dispersion_tbl,
  "finance" = finance_dispersion_tbl,
  "labour" = labour_dispersion_tbl
) |> 
  map( ~clean_up(.x)) |> 
  bind_rows(.id = "sector") |> 
  pivot_wider(
    id_cols = date,
    names_from = c(sector, horizon),
    values_from = sd,
    names_sep = "_"
  )


# Export ---------------------------------------------------------------
artifacts_expectations_dispersion <- list (
   combined_tbl = combined_tbl
)

write_rds(artifacts_expectations_dispersion, file = here("Outputs", "artifacts_expectations_dispersion.rds"))


