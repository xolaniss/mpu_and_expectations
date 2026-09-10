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
    policy_rate = 2
  ) |> 
  mutate(policy_rate = as.numeric(policy_rate)) |> 
  filter(!is.na(policy_rate))
  
 
news_based_mpu_tbl <- 
  read_excel(here("Data", "MPuncertainty.xlsx")) |> 
  rename(
    date = 1,
    news_based_mpu = 2
  ) |> 
  mutate(date = as.Date(date)) |> 
  summarise_by_time(date, "quarter", news_based_mpu = mean(news_based_mpu, na.rm = TRUE))



# Graphing ---------------------------------------------------------------
daily_repo_tbl <- 
  daily_repo_tbl |> 
  mutate(date = as.Date(date)) |> 
  summarise_by_time(date, "quarter", policy_rate = mean(policy_rate, na.rm = TRUE)) |> 
  ggplot(aes(x = date, y = policy_rate)) +
  geom_line() +
  theme_minimal() +
  labs(y = "Policy Rate", x = " ")
  



news_based_mpu_gg <- 
  news_based_mpu_tbl |> 
  ggplot(aes(x = date, y = news_based_mpu)) +
  geom_line() +
  theme_minimal() +
  labs(y = "News Based MPU", x = " ")

# Export ---------------------------------------------------------------
artifacts_mpu_measures <- list (
  news_based = list(
    news_based_mpu_tbl = news_based_mpu_tbl,
    news_based_mpu_gg = news_based_mpu_gg
  ),
  daily_repo_tbl = daily_repo_tbl
)

write_rds(artifacts_mpu_measures, file = here("Outputs", "artifacts_mpu_measures.rds"))


