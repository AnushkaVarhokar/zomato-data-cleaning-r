# ============================================================
# Zomato Bangalore Restaurants - Data Cleaning & Exploratory Analysis
# ============================================================

# ------------------------------------------------------------
# Step 1: Install Required Packages (run once)
# ------------------------------------------------------------
install.packages("tidyverse")
install.packages("janitor")
install.packages("fastDummies")
install.packages("corrplot")

# ------------------------------------------------------------
# Step 2: Load Packages
# ------------------------------------------------------------
library(tidyverse)
library(janitor)
library(fastDummies)
library(corrplot)

# ------------------------------------------------------------
# Step 3: Import the Dataset
# ------------------------------------------------------------
zomato <- read_csv("zomato.csv")

# ------------------------------------------------------------
# Step 4: Initial Inspection
# ------------------------------------------------------------
dim(zomato)
glimpse(zomato)
head(zomato, 5)
summary(zomato)

# ------------------------------------------------------------
# Step 5: Clean Column Names
# ------------------------------------------------------------
zomato <- zomato %>% clean_names()
names(zomato)

# ------------------------------------------------------------
# Step 6: Remove Redundant Columns
# ------------------------------------------------------------
zomato <- zomato %>% select(-x1, -unnamed_0)
names(zomato)

# ------------------------------------------------------------
# Step 7: Check for Duplicate Rows
# ------------------------------------------------------------
sum(duplicated(zomato))

# ------------------------------------------------------------
# Step 8: Identify Missing Values
# ------------------------------------------------------------
colSums(is.na(zomato))

# ------------------------------------------------------------
# Step 9: Handle Missing Values
# ------------------------------------------------------------

# Impute missing average cost with the median (robust to right-skew)
zomato <- zomato %>%
  mutate(avg_cost_two_people = ifelse(
    is.na(avg_cost_two_people),
    median(avg_cost_two_people, na.rm = TRUE),
    avg_cost_two_people
  ))

# Flag missing ratings instead of imputing (preserves data integrity)
zomato <- zomato %>%
  mutate(rating_missing_flag = is.na(rate_out_of_5))

# Verify
colSums(is.na(zomato))

# ------------------------------------------------------------
# Step 10: Trim Whitespace in Text Columns
# ------------------------------------------------------------
zomato <- zomato %>%
  mutate(across(where(is.character), str_trim))

# ------------------------------------------------------------
# Step 11: Split Multi-Valued Column - Cuisines
# ------------------------------------------------------------
zomato <- zomato %>%
  mutate(primary_cuisine = str_trim(str_split_i(cuisines_type, ",", 1)))

zomato %>% select(cuisines_type, primary_cuisine) %>% head(10)

# ------------------------------------------------------------
# Step 12: Split Multi-Valued Column - Restaurant Type
# ------------------------------------------------------------
zomato <- zomato %>%
  mutate(primary_restaurant_type = str_trim(str_split_i(restaurant_type, ",", 1)))

zomato %>% select(restaurant_type, primary_restaurant_type) %>% head(10)

# ------------------------------------------------------------
# Step 13: Clean Restaurant Name Artifacts
# ------------------------------------------------------------

# Inspect names starting with non-alphanumeric characters
zomato %>%
  filter(str_detect(restaurant_name, "^[^A-Za-z0-9]")) %>%
  select(restaurant_name)

# Remove leading "'@ " artifacts (data entry/scraping issue),
# while leaving genuine "#" branding untouched
zomato <- zomato %>%
  mutate(restaurant_name = str_replace(restaurant_name, "^'@\\s*", ""))

# Verify
zomato %>%
  filter(str_detect(restaurant_name, "^[^A-Za-z0-9]")) %>%
  select(restaurant_name)

# ------------------------------------------------------------
# Step 14: Save Cleaned Dataset (checkpoint)
# ------------------------------------------------------------
write_csv(zomato, "zomato_cleaned.csv")

# ------------------------------------------------------------
# Step 15: Outlier Detection (IQR Method) - avg_cost_two_people
# ------------------------------------------------------------
boxplot(zomato$avg_cost_two_people, main = "Avg Cost for Two - Outlier Check")
boxplot(zomato$num_of_ratings, main = "Number of Ratings - Outlier Check")

Q1 <- quantile(zomato$avg_cost_two_people, 0.25)
Q3 <- quantile(zomato$avg_cost_two_people, 0.75)
IQR_val <- Q3 - Q1

lower_bound <- Q1 - 1.5 * IQR_val
upper_bound <- Q3 + 1.5 * IQR_val

outliers_cost <- zomato %>%
  filter(avg_cost_two_people < lower_bound | avg_cost_two_people > upper_bound)
nrow(outliers_cost)

# Investigate the outliers
summary(outliers_cost$avg_cost_two_people)

outliers_cost %>%
  select(restaurant_name, restaurant_type, avg_cost_two_people) %>%
  arrange(desc(avg_cost_two_people)) %>%
  head(10)

# Decision: keep outliers (genuine high-end restaurants), flag instead of removing
zomato <- zomato %>%
  mutate(is_cost_outlier = avg_cost_two_people < lower_bound | avg_cost_two_people > upper_bound)

table(zomato$is_cost_outlier)

# ------------------------------------------------------------
# Step 16: Normalization (Min-Max Scaling)
# ------------------------------------------------------------
zomato <- zomato %>%
  mutate(
    rate_normalized = (rate_out_of_5 - min(rate_out_of_5, na.rm = TRUE)) /
                       (max(rate_out_of_5, na.rm = TRUE) - min(rate_out_of_5, na.rm = TRUE)),
    cost_normalized = (avg_cost_two_people - min(avg_cost_two_people)) /
                       (max(avg_cost_two_people) - min(avg_cost_two_people))
  )

zomato %>%
  select(rate_out_of_5, rate_normalized, avg_cost_two_people, cost_normalized) %>%
  head(5)

# ------------------------------------------------------------
# Step 17: Encoding Categorical Variables
# ------------------------------------------------------------

# a) Binary encoding for Yes/No columns
zomato <- zomato %>%
  mutate(
    online_order_encoded = ifelse(online_order == "Yes", 1, 0),
    table_booking_encoded = ifelse(table_booking == "Yes", 1, 0)
  )

zomato %>%
  select(online_order, online_order_encoded, table_booking, table_booking_encoded) %>%
  head(5)

# b) One-hot encoding for restaurant type (kept in a separate dataframe)
zomato_encoded <- dummy_cols(zomato, select_columns = "primary_restaurant_type",
                              remove_first_dummy = FALSE, remove_selected_columns = FALSE)

ncol(zomato)
ncol(zomato_encoded)
names(zomato_encoded)[1:20]

# ------------------------------------------------------------
# Step 18: Correlation Analysis
# ------------------------------------------------------------
numeric_data <- zomato %>% select(rate_out_of_5, num_of_ratings, avg_cost_two_people)
cor(numeric_data, use = "complete.obs")

corrplot(cor(numeric_data, use = "complete.obs"), method = "color", addCoef.col = "black")

# ------------------------------------------------------------
# Step 19: Exploratory Visualizations
# ------------------------------------------------------------

# a) Distribution of Ratings
ggplot(zomato, aes(x = rate_out_of_5)) +
  geom_histogram(binwidth = 0.2, fill = "steelblue", color = "white") +
  labs(title = "Distribution of Ratings", x = "Rating", y = "Count")

# b) Cost Distribution by Restaurant Type (top 10 most common types)
top_types <- zomato %>% count(primary_restaurant_type, sort = TRUE) %>% head(10)

zomato %>%
  filter(primary_restaurant_type %in% top_types$primary_restaurant_type) %>%
  ggplot(aes(x = primary_restaurant_type, y = avg_cost_two_people)) +
  geom_boxplot(fill = "coral") +
  coord_flip() +
  labs(title = "Cost Distribution by Restaurant Type", x = "", y = "Avg Cost for Two")

# c) Rating by Online Order Availability
ggplot(zomato, aes(x = online_order, y = rate_out_of_5)) +
  geom_boxplot(fill = "lightgreen") +
  labs(title = "Rating by Online Order Availability")

# ------------------------------------------------------------
# Step 20: Save Final Processed Dataset
# ------------------------------------------------------------
write_csv(zomato, "zomato_final_processed.csv")
write_csv(zomato_encoded, "zomato_onehot_encoded.csv")

# ============================================================
# Step 21 Statistical Analysis
# ============================================================
install.packages("moments")
library(moments)

zomato %>%
  summarise(
    rating_mean = mean(rate_out_of_5, na.rm = TRUE),
    rating_sd = sd(rate_out_of_5, na.rm = TRUE),
    rating_skew = skewness(rate_out_of_5, na.rm = TRUE),
    rating_kurtosis = kurtosis(rate_out_of_5, na.rm = TRUE),
    cost_mean = mean(avg_cost_two_people),
    cost_sd = sd(avg_cost_two_people))
#--------------------------------------------------------------
# Step 22 t-test: rating by online order
#--------------------------------------------------------------
t.test(rate_out_of_5 ~ online_order, data = zomato)
#--------------------------------------------------------------
# Step 23 — ANOVA: cost across restaurant types
-------- --- -------------------------------------------------
anova_model <- aov(avg_cost_two_people ~ primary_restaurant_type, data = zomato)
summary(anova_model)
#--------------------------------------------------------------
# Step 24 chisq.test(table(zomato$online_order, zomato$table_booking))
#--------------------------------------------------------------
chisq.test(table(zomato$online_order, zomato$table_booking))
#--------------------------------------------------------------
# Step 25 Correlation significance
#--------------------------------------------------------------
  cor.test(zomato$rate_out_of_5, zomato$avg_cost_two_people)
cor.test(zomato$rate_out_of_5, zomato$num_of_ratings)
#--------------------------------------------------------------
# Step 26 — Train/test split  
#--------------------------------------------------------------
install.packages("caret")
library(caret)
set.seed(123)
model_data <- zomato %>% filter(!is.na(rate_out_of_5))
split_index <- createDataPartition(model_data$rate_out_of_5, p = 0.8, list = FALSE)
train_data <- model_data[split_index, ]
test_data <- model_data[-split_index, ]
#--------------------------------------------------------------
# Step 27 — Baseline linear regression
#--------------------------------------------------------------
library(caret)
set.seed(123)
train_data <- model_data[split_index, ]
test_data <- model_data[-split_index, ]
nrow(train_data)
nrow(test_data)
lm_model <- lm(rate_out_of_5 ~ avg_cost_two_people + num_of_ratings + 
                 online_order_encoded + table_booking_encoded + primary_restaurant_type, 
               data = train_data)
summary(lm_model) 
names(zomato)
#--------------------------------------------------------------
# Step 28 — Evaluate linear model
----------------------------------------------------
lm_model <- lm(
    rate_out_of_5 ~ avg_cost_two_people +
      num_of_ratings +
      online_order_encoded +
      table_booking_encoded,
    data = train_data
  )
predictions_lm <- predict(lm_model, test_data)

postResample(
  predictions_lm,
  test_data$rate_out_of_5
)

par(mfrow = c(2,2))
plot(lm_model)
#--------------------------------------------------------------
# Step 29 — Random Forest model
#--------------------------------------------------------------
install.packages("randomForest")
library(randomForest)

rf_model <- randomForest(rate_out_of_5 ~ avg_cost_two_people + num_of_ratings + 
                           online_order_encoded + table_booking_encoded + primary_restaurant_type,
                         data = train_data, importance = TRUE)
predictions_rf <- predict(rf_model, test_data)
postResample(predictions_rf, test_data$rate_out_of_5)
#--------------------------------------------------------------
# Step 30 - Feature importance
#--------------------------------------------------------------
importance(rf_model)
varImpPlot(rf_model)