# Zomato Bangalore Restaurants — Data Cleaning & EDA in R

A data cleaning, preprocessing, and exploratory data analysis project built in R, using the Zomato Bangalore Restaurants dataset. The project focuses on realistic messy-data challenges: missing values, multi-valued categorical fields, inconsistent text formatting, outliers, and mixed variable types.

## 📊 Project Overview

This project walks through a full data analysis pipeline:

- Importing and inspecting a raw, messy CSV dataset
- Cleaning column names and removing redundant columns
- Handling missing values with different strategies per variable (median imputation vs. flagging)
- Detecting and evaluating outliers using the IQR method
- Splitting multi-valued categorical columns (cuisines, restaurant type)
- Normalizing numeric variables (min-max scaling)
- Encoding categorical variables (binary + one-hot encoding)
- Correlation analysis and exploratory visualizations
- Summarizing key insights

## 🗂️ Repository Structure

```
├── zomato.csv                          # Original raw dataset
├── zomato_cleaned.csv                  # Cleaned dataset (output of the R script)
├── data_cleaning_analysis.R            # Full R script — cleaning, transformation, EDA
├── Zomato_Data_Cleaning_Report.docx    # Full written report with code, outputs, and visuals
├── plots/                              # Saved visualizations (PNG screenshots)
│   ├── correlation_heatmap.png
│   ├── rating_distribution.png
│   ├── cost_by_restaurant_type.png
│   └── rating_by_online_order.png
└── README.md
```

## 🧰 Tools & Packages

- **R** / **RStudio**
- `tidyverse` — data import, manipulation, visualization
- `janitor` — column name cleaning
- `fastDummies` — one-hot encoding
- `corrplot` — correlation heatmap visualization

## 🔑 Key Steps

1. **Data Import & Inspection** — loaded the raw CSV, reviewed structure with `glimpse()` and `summary()`
2. **Cleaning** — standardized column names, removed junk index columns, checked for duplicates
3. **Missing Values** — imputed `avg_cost_two_people` with the median; flagged (rather than imputed) missing `rate_out_of_5` values
4. **Outlier Detection** — used the IQR method on cost; investigated and confirmed outliers were genuine high-end restaurants, so flagged rather than removed them
5. **Transformation** — min-max normalized rating and cost; binary-encoded Yes/No columns; one-hot encoded restaurant type
6. **Exploratory Analysis** — correlation matrix/heatmap, rating distribution, cost by restaurant type, rating vs. online order availability

## 📈 Key Insights

- Rating, number of ratings, and average cost are only weakly correlated with each other (r ≈ 0.34–0.38) — price and popularity are not strong predictors of rating.
- Ratings cluster tightly around 3.5, with very few restaurants rated below 2.5 or above 4.5.
- Cost varies significantly by restaurant type — **Bar** and **Casual Dining** are the most expensive categories; **Beverage Shop**, **Bakery**, and **Quick Bites** are consistently cheap.
- Online order availability has only a small positive association with rating.

## 📄 Full Report

See [`Zomato_Data_Cleaning_Report.docx`](./Zomato_Data_Cleaning_Report.docx) for the complete write-up, including all R code, console outputs, and visualizations with interpretation.

## 📦 Dataset Source

[Zomato Bangalore Restaurants Dataset](https://www.kaggle.com/datasets/rishikeshkonapure/zomato) (Kaggle)
