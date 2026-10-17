# Week 1: Data Cleaning and Preliminary Analysis with R
# Dataset: airquality (base R datasets package)
# Run: source("week1_analysis.R")

packages <- c("ggplot2", "dplyr", "tidyr", "forcats")
missing_packages <- packages[!vapply(packages, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing_packages) > 0) {
  install.packages(missing_packages, repos = "https://cloud.r-project.org")
}
library(ggplot2)
library(dplyr)
library(tidyr)
library(forcats)
dir.create("outputs", showWarnings = FALSE)

data("airquality", package = "datasets")
raw <- airquality
write.csv(raw, "outputs/airquality_raw.csv", row.names = FALSE)
cat("Dimensions:\n"); print(dim(raw))
cat("\nStructure:\n"); str(raw)
cat("\nSummary before cleaning:\n"); print(summary(raw))

missing_counts <- data.frame(
  variable = names(raw),
  missing_n = vapply(raw, function(x) sum(is.na(x)), integer(1)),
  missing_pct = round(vapply(raw, function(x) mean(is.na(x))*100, numeric(1)), 2)
)
print(missing_counts)
write.csv(missing_counts, "outputs/missingness_audit.csv", row.names = FALSE)

clean <- raw %>% mutate(
  Month = factor(Month, levels = 5:9,
    labels = c("May", "June", "July", "August", "September")),
  Day = as.integer(Day)
)

for (v in c("Ozone", "Solar.R")) {
  clean[[paste0(v, "_was_missing")]] <- is.na(clean[[v]])
  clean <- clean %>% group_by(Month) %>%
    mutate("{v}" := ifelse(is.na(.data[[v]]),
      median(.data[[v]], na.rm = TRUE), .data[[v]])) %>% ungroup()
  clean[[v]][is.na(clean[[v]])] <- median(clean[[v]], na.rm = TRUE)
}

outlier_flags <- function(x) {
  q <- quantile(x, c(.25, .75), na.rm = TRUE)
  iqr <- q[2] - q[1]
  x < q[1] - 1.5*iqr | x > q[2] + 1.5*iqr
}
clean <- clean %>% mutate(
  Ozone_outlier = outlier_flags(Ozone),
  SolarR_outlier = outlier_flags(Solar.R),
  Wind_outlier = outlier_flags(Wind),
  Temp_outlier = outlier_flags(Temp)
)
outlier_summary <- data.frame(
  variable = c("Ozone", "Solar.R", "Wind", "Temp"),
  flagged_n = c(sum(clean$Ozone_outlier), sum(clean$SolarR_outlier),
    sum(clean$Wind_outlier), sum(clean$Temp_outlier))
)
print(outlier_summary)
write.csv(outlier_summary, "outputs/outlier_summary.csv", row.names = FALSE)

minmax <- function(x) {
  rng <- range(x, na.rm = TRUE)
  if (diff(rng) == 0) return(rep(0, length(x)))
  (x - rng[1]) / diff(rng)
}
clean <- clean %>% mutate(
  Ozone_scaled = minmax(Ozone), SolarR_scaled = minmax(Solar.R),
  Wind_scaled = minmax(Wind), Temp_scaled = minmax(Temp)
)
month_dummies <- as.data.frame(model.matrix(~ Month - 1, data = clean))
names(month_dummies) <- make.names(names(month_dummies))
model_ready <- bind_cols(clean, month_dummies)
write.csv(clean, "outputs/airquality_clean.csv", row.names = FALSE)
write.csv(model_ready, "outputs/airquality_model_ready.csv", row.names = FALSE)

numeric_data <- clean %>% select(Ozone, Solar.R, Wind, Temp)
descriptive <- data.frame(
  variable = names(numeric_data),
  mean = vapply(numeric_data, mean, numeric(1)),
  median = vapply(numeric_data, median, numeric(1)),
  sd = vapply(numeric_data, sd, numeric(1)),
  min = vapply(numeric_data, min, numeric(1)),
  max = vapply(numeric_data, max, numeric(1))
)
descriptive[, -1] <- lapply(descriptive[, -1], round, 2)
print(descriptive)
write.csv(descriptive, "outputs/descriptive_statistics.csv", row.names = FALSE)
cor_matrix <- cor(numeric_data, use = "pairwise.complete.obs")
print(round(cor_matrix, 2))
write.csv(round(cor_matrix, 3), "outputs/correlation_matrix.csv")

monthly <- clean %>% group_by(Month) %>% summarise(
  observations = n(), mean_ozone = mean(Ozone),
  mean_temp = mean(Temp), mean_wind = mean(Wind), .groups = "drop"
)
print(monthly)
write.csv(monthly, "outputs/monthly_summary.csv", row.names = FALSE)

p1 <- ggplot(clean, aes(Month, Ozone, fill = Month)) +
  geom_boxplot(show.legend = FALSE) +
  labs(title = "Ozone distribution by month", x = "Month", y = "Ozone (ppb)") +
  theme_minimal()
ggsave("outputs/ozone_by_month.png", p1, width = 8, height = 5, dpi = 150)

p2 <- ggplot(clean, aes(Temp, Ozone)) + geom_point(alpha = .7) +
  geom_smooth(method = "lm", se = TRUE, color = "#276FBF") +
  labs(title = "Ozone versus temperature", x = "Temperature (°F)", y = "Ozone (ppb)") +
  theme_minimal()
ggsave("outputs/ozone_vs_temperature.png", p2, width = 8, height = 5, dpi = 150)

p3 <- ggplot(missing_counts, aes(reorder(variable, -missing_n), missing_n)) +
  geom_col(fill = "#276FBF") +
  labs(title = "Missing values before cleaning", x = "Variable", y = "Missing count") +
  theme_minimal()
ggsave("outputs/missing_values.png", p3, width = 8, height = 5, dpi = 150)

stopifnot(nrow(clean) == nrow(raw))
stopifnot(!anyNA(clean$Ozone), !anyNA(clean$Solar.R))
stopifnot(all(clean$Ozone_scaled >= 0 & clean$Ozone_scaled <= 1))
stopifnot(all(clean$Temp_scaled >= 0 & clean$Temp_scaled <= 1))
cat("\nValidation passed. See outputs/ for tables, cleaned data, and plots.\n")
