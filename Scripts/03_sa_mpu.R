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

daily_fra_tbl <- 
  read_excel()

market_based_mpu_tbl <- 
  daily_repo_tbl |> 
  inner_join(daily_fra_tbl, .by = "date") |> 
  mutate(market_based_measure = daily_fra - daily_repo) |> 
  summarise_by_time(date, "quarter", market_based_mpu = mean(market_based_mpu, na.rm = TRUE))
 
news_based_mpu_tbl <- 
  read_excel(here("Data", "MPuncertainty.xlsx")) |> 
  rename(
    date = 1,
    news_based_mpu = 2
  ) |> 
  mutate(date = as.Date(date)) |> 
  summarise_by_time(date, "quarter", news_based_mpu = mean(news_based_mpu, na.rm = TRUE))

# Graphing ---------------------------------------------------------------
market_based_mpu_gg <- 
  market_based_mpu_tbl |> 
  mutate(date = as.Date(date)) |> 

  ggplot(aes(x = date, y = market_based_mpu)) +
  geom_line() +
  theme_minimal() +
  labs(y = "Market Based MPU", x = " ")
  
news_based_mpu_gg <- 
  news_based_mpu_tbl |> 
  ggplot(aes(x = date, y = news_based_mpu)) +
  geom_line() +
  theme_minimal() +
  labs(y = "News Based MPU", x = " ")

# Export ---------------------------------------------------------------
artifacts_mpu_measures <- list(
  news_based_mpu = list(
    news_based_mpu_tbl = news_based_mpu_tbl,
    news_based_mpu_gg = news_based_mpu_gg
  ),
  market_based_mpu = list(
    market_based_mpu_tbl = market_based_mpu_tbl,
    market_based_mpu_gg = market_based_mpu_gg
  )
)

write_rds(artifacts_mpu_measures, file = here("Outputs", "artifacts_mpu_measures.rds"))


