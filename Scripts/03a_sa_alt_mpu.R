# Description
# news based mpu from Codera - XS Aug 2026
# Preliminaries -----------------------------------------------------------
library(here)

# Functions ---------------------------------------------------------------
source(here("packages.R"))
source(here("Functions", "fx_plot.R"))

# Import -------------------------------------------------------------
news_based_mpu_tbl <- 
  read_excel(here("Data", "MPuncertainty.xlsx")) |> 
  rename(
    date = 1,
    news_based_mpu = 2
  ) |> 
  mutate(date = as.Date(date)) |> 
  summarise_by_time(date, "quarter", news_based_mpu = mean(news_based_mpu, na.rm = TRUE))


# Graphing ---------------------------------------------------------------
news_based_mpu_gg <- 
  news_based_mpu_tbl |> 
  ggplot(aes(x = date, y = news_based_mpu)) +
  geom_line() +
  theme_minimal() +
  labs(y = "News Based MPU", x = " ")

# Export ---------------------------------------------------------------
artifacts_news_based_mpu <- list (
  news_based_mpu_tbl = news_based_mpu_tbl,
  news_based_mpu_gg = news_based_mpu_gg
)

write_rds(artifacts_news_based_mpu, file = here("Outputs", "artifacts_news_based_mpu.rds"))


