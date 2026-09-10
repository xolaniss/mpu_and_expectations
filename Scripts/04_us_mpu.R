# Description
# US EPU-Monetary policy based on 2000 US newspapers - Xolani August 2026

# Preliminaries -----------------------------------------------------------
library(here)

# Functions ---------------------------------------------------------------
source(here("packages.R"))
source(here("Functions", "fx_plot.R"))

# Import -------------------------------------------------------------
us_mpu_tbl <- 
  read_excel(here("Data", "EPUMONETARY.xlsx"),sheet = 2) |> 
  rename(
    date = 1,
    us_mpu = 2
  ) 
  summarise_by_time(date, .by = "quarter", us_mpu = mean(us_mpu, na.rm = TRUE))

# Graphing ---------------------------------------------------------------
us_mpu_gg <- 
  us_mpu_tbl |> 
  ggplot(aes(x = date, y = us_mpu)) +
  geom_line() +
  theme_minimal() +
  labs(y = "US Monetary Policy Uncertainty", x = " ")
  

# Export ---------------------------------------------------------------
artifacts_us_monetary_policy_uncertainty <- list (
 us_mpu_tbl = us_mpu_tbl,
 us_mpu_gg = us_mpu_gg
)

write_rds(artifacts_us_monetary_policy_uncertainty, file = here("Outputs", "artifacts_us_monetary_policy_uncertainty.rds"))


