# Week 1 — Data Cleaning and Preliminary Analysis with R

This project demonstrates a reproducible cleaning and exploratory analysis workflow using R's public `datasets::airquality` dataset.

## Contents
- `week1_analysis.R` — full workflow: inspection, missingness audit, median imputation by month, missingness flags, IQR outlier screening, min-max scaling, Month one-hot encoding, descriptive statistics, correlations, monthly summary, and PNG charts.
- `SUBMISSION_CHECKLIST.md` — final evidence checklist.

## Dataset
The dataset contains 153 daily observations and six variables for New York air quality in May–September 1973. `Ozone` has 37 missing values and `Solar.R` has 7. It is included with base R, so a separate download is not required.

## Run
1. Install R and RStudio.
2. Open this folder as the working directory.
3. Run `source("week1_analysis.R")`.
4. Allow the script to install `ggplot2`, `dplyr`, `tidyr`, and `forcats` if needed.
5. Review the generated `outputs/` folder.

The script preserves original units, adds scaled columns, flags rather than automatically deletes potential outliers, and exports clean/model-ready CSV files.

Note: run the script and insert your own RStudio screenshots and exact computed results into the DOCX report before submission.