# Description
# sa mpu - XS Aug 2026
# Preliminaries -----------------------------------------------------------
library(here)

# Functions ---------------------------------------------------------------
source(here("packages.R"))
source(here("Functions", "fx_plot.R"))

# Import -------------------------------------------------------------
daily_repo_tbl <- 
  read_excel(here("Data", "daily_repo_rates.xlsx"), skip = 4) |> 
  mutate(date = as.Date(DESCRIPTION)) |> 
  filter(date <= "2026-08-01") |> 
  select(date, 2) |> 
  rename(
    daily_policy_rate = 2
  ) |> 
  mutate(daily_policy_rate = as.numeric(daily_policy_rate)) |> 
  filter(!is.na(daily_policy_rate))

daily_fra_tbl <- 
  read_excel(here("Data", "FRA 1x4.xlsx")) |> 
  janitor::clean_names() |> 
  rename(
    daily_fra = 2
  )

market_based_mpu_tbl <- 
  daily_repo_tbl |> 
  inner_join(daily_fra_tbl, by = "date") |> 
  mutate(market_based_mpu = daily_fra - daily_policy_rate) |> 
  summarise_by_time(date, "quarter", market_based_mpu = mean(market_based_mpu, na.rm = TRUE))
 

# Graphing ---------------------------------------------------------------
market_based_mpu_gg <- 
  market_based_mpu_tbl |> 
  mutate(date = as.Date(date)) |> 

  ggplot(aes(x = date, y = market_based_mpu)) +
  geom_line() +
  theme_minimal() +
  labs(y = "Market Based MPU", x = " ")
  


# Export ---------------------------------------------------------------
artifacts_market_mpu <- list(
    market_based_mpu_tbl = market_based_mpu_tbl,
    market_based_mpu_gg = market_based_mpu_gg
)

write_rds(artifacts_market_mpu, file = here("Outputs", "artifacts_market_mpu.rds"))


