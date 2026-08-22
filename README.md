# Zomato Bangalore Restaurants — Data Cleaning, Statistical & Predictive Analysis in R

A data cleaning, exploratory, statistical, and predictive analysis project built in R, using the Zomato Bangalore Restaurants dataset. The project focuses on realistic messy-data challenges: missing values, multi-valued categorical fields, inconsistent text formatting, outliers, and mixed variable types — and extends into statistical testing and regression modeling to predict restaurant ratings.

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
- Descriptive statistics (skewness, kurtosis) on the ratings distribution
- Predictive modeling: Linear Regression vs. Random Forest to predict restaurant rating
- Model evaluation (RMSE, R², MAE), residual diagnostics, and feature importance
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
7. **Descriptive Statistics** — skewness and kurtosis of the ratings distribution to formally confirm its shape
8. **Predictive Modeling** — 80/20 train-test split; built and compared a Linear Regression model and a Random Forest model to predict restaurant rating
9. **Model Evaluation** — compared RMSE, R², and MAE across models; reviewed residual diagnostic plots for the linear model; extracted feature importance from the Random Forest model

## 📈 Key Insights

- Rating, number of ratings, and average cost are only weakly correlated with each other (r ≈ 0.34–0.38) — price and popularity are not strong predictors of rating.
- Ratings cluster tightly around 3.5, with very few restaurants rated below 2.5 or above 4.5, and are statistically near-symmetric (skewness ≈ -0.06) with slightly fewer extremes than a normal distribution (kurtosis ≈ 2.46).
- Cost varies significantly by restaurant type — **Bar** and **Casual Dining** are the most expensive categories; **Beverage Shop**, **Bakery**, and **Quick Bites** are consistently cheap.
- Online order availability has only a small positive association with rating.
- A **Random Forest** model predicts restaurant rating considerably better than linear regression (**R² = 0.44** vs. **0.26**), showing the relationship between cost, popularity, and rating is meaningfully non-linear.
- **Number of ratings** is the single strongest predictor of rating, ahead of cost and service features — popularity is more informative of perceived quality than price alone.

## 🤖 Model Performance Summary

| Model | RMSE | R² | MAE |
|---|---|---|---|
| Linear Regression | 0.394 | 0.259 | 0.319 |
| **Random Forest** | **0.353** | **0.444** | **0.283** |

## 📄 Full Report

See [`Zomato_Data_Cleaning_Report.docx`](./Zomato_Data_Cleaning_Report.docx) for the complete write-up, including all R code, console outputs, and visualizations with interpretation.

## 📦 Dataset Source

[Zomato Bangalore Restaurants Dataset](https://www.kaggle.com/datasets/rishikeshkonapure/zomato) (Kaggle)
