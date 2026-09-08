## ============================================================
## USDZAR GARCH(1,1) conditional volatility series
## ============================================================
## Purpose: estimate a daily (or other frequency) conditional
## volatility series for USDZAR to use as an exchange-rate
## uncertainty proxy in the dispersion regressions.
##
## Package: rugarch (the standard workhorse for univariate
## GARCH in R; well documented, actively maintained, integrates
## cleanly with xts time series).
## ============================================================

##  Packages ------------------------------------------
# install.packages(c("rugarch", "xts", "quantmod", "PerformanceAnalytics"))
library(rugarch)
library(xts)
library(quantmod)   # only needed if pulling data via getSymbols; drop if importing your own series

##  Get the USDZAR price series ------------------------
usdzar_tbl <- read_excel(here("Data", "usdzar.xlsx"), skip = 2) |> rename( date = 1, rate = 2)

usdzar_xts <- xts(usdzar_tbl$rate, order.by = usdzar_tbl$date)
colnames(usdzar_xts) <- "USDZAR"

##  Compute log returns ---------------------------------
## GARCH is fit on returns, not levels - the levels series is
## non-stationary (a random walk, roughly), so mean/variance
## dynamics of interest live in the return series.

usdzar_ret <- diff(log(usdzar_xts))
usdzar_ret <- na.omit(usdzar_ret) * 100   # scale to % for numerical stability in optimisation

## (Optional but recommended) inspect for ARCH effects --
## Confirms GARCH is warranted before you fit one - a referee
## will expect to see this justified, not just assumed.

# Ljung-Box test on squared returns
Box.test(usdzar_ret^2, lag = 10, type = "Ljung-Box")

# ARCH LM test
# install.packages("FinTS")
# FinTS::ArchTest(usdzar_ret, lags = 10)

## Specify the GARCH(1,1) model -------------------------
## Mean equation: start with a constant mean (armaOrder = c(0,0)).
## Check the mean-equation residual autocorrelation (step 4-style
## diagnostics) - if there's serial correlation in returns
## themselves, add AR/MA terms to the mean spec before moving on.
##
## Variance equation: standard GARCH(1,1); std or sstd
## distribution is usually a better fit than normal for FX
## returns (fat tails), so both are specified below for comparison.

spec_norm <- ugarchspec(
  variance.model = list(model = "sGARCH", garchOrder = c(1, 1)),
  mean.model     = list(armaOrder = c(0, 0), include.mean = TRUE),
  distribution.model = "norm"
)

spec_std <- ugarchspec(
  variance.model = list(model = "sGARCH", garchOrder = c(1, 1)),
  mean.model     = list(armaOrder = c(0, 0), include.mean = TRUE),
  distribution.model = "std"   # Student-t; captures fat tails typical of FX returns
)

## Fit the model(s) --------------------------------------

fit_norm <- ugarchfit(spec = spec_norm, data = usdzar_ret)
fit_std  <- ugarchfit(spec = spec_std,  data = usdzar_ret)

## Compare fit via information criteria - pick the better-fitting
## distribution before proceeding (std usually wins for FX).
infocriteria(fit_norm)
infocriteria(fit_std)

## Use whichever wins from here on - assume std below.
fit <- fit_std

show(fit)   # coefficient table, robust std errors, diagnostic tests (Ljung-Box on
# standardised residuals and squared standardised residuals, ARCH-LM,
# sign bias test) - check these before trusting the series

## Extract the conditional volatility series --------------
## This IS your uncertainty proxy - the fitted conditional
## standard deviation at each date, in the same % units as the
## return series (undo the earlier *100 scaling if you need
## decimal units).

cond_vol <- sigma(fit)                     # xts series of conditional SD (%, daily)
cond_var <- sigma(fit)^2                   # conditional variance, if that's the form you want

cond_vol_annualised <- cond_vol * sqrt(252)  # if you want an annualised comparator

## Extract standardised residuals for diagnostics -----------
## These are what you check for remaining structure - NOT the
## volatility series itself. If GARCH(1,1) is adequate, these
## should look like iid noise (no autocorrelation, no remaining
## ARCH effects).

std_resid <- residuals(fit, standardize = TRUE)

Box.test(std_resid^2, lag = 10, type = "Ljung-Box")   # should NOT reject if model is adequate

## Aggregate to your regression frequency --------------------
## Your dispersion series is quarterly (BER survey). Convert the
## daily conditional volatility to quarterly, e.g. quarterly mean
## or end-of-quarter level - decide based on whether you want an
## average uncertainty measure over the quarter or a point-in-time
## snapshot, and be consistent with how you construct the SA and
## US policy rate uncertainty series so all three are comparable.

cond_vol_df <- data.frame(date = index(cond_vol), vol = coredata(cond_vol))
cond_vol_df$quarter <- as.yearqtr(cond_vol_df$date)

quarterly_vol_tbl <- aggregate(vol ~ quarter, data = cond_vol_df, FUN = mean) |> 
  as_tibble() |>  
  mutate(quarter = as.Date(quarter))


##  Sanity-check plot -----------------------------------------
quarterly_vol_gg <- 
  quarterly_vol_tbl |> 
  ggplot(aes(x = quarter, y = vol)) + 
  geom_line() + 
  labs(title = "Quarterly Volatility", x = "Quarter", y = "Volatility") +
  theme_minimal() +
  scale_x_date(
    date_breaks = "2 years",
    labels = function(x) paste0(format(x, "%Y"), " ", quarters(x))
  ) +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1))

## ---- 11. Export -----------------------------------------------------
write_rds(
  list(
    quarterly_vol_tbl = quarterly_vol_tbl,
    quarterly_vol_gg = quarterly_vol_gg
  ),
  here("Outputs", "artifacts_rand_vol.rds")
)
