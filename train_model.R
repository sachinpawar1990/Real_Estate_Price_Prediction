# Load required libraries
library(ggplot2)
library(plyr)
library(dplyr)
library(corrplot)
library(caret)
library(gridExtra)
library(scales)
library(Rmisc)
library(ggrepel)
library(randomForest)
library(psych)
library(xgboost)
library(mice)
library(Boruta)
library(glmnet)
library(Metrics)

# Function to load data
load_data <- function(file_path) {
  read.csv(file_path, stringsAsFactors = FALSE)
}

# Function for initial data analysis and visualization
analyze_data <- function(data) {
  # Simple analysis of the data and target variable
  print(dim(data))
  ggplot(data = data[!is.na(data$y), ], aes(x = y)) +
    geom_histogram(fill = "blue", binwidth = 50) +
    scale_x_continuous(breaks = seq(300, 850, by = 50), labels = scales::comma())
}

# Function to handle missing data with MICE
handle_missing_data <- function(data, vars_to_keep) {
  raw_data2 <- data[, (names(data) %in% vars_to_keep)]
  raw_data2x <- raw_data2 %>% select(-c("y"))
  imputed_Data <- mice(raw_data2x, m = 3, maxit = 10, method = 'pmm', seed = 500)
  completeData <- complete(imputed_Data, 1)
  completeData <- cbind(completeData, y = data[, c("y")])
  
  # Save imputed data
  saveRDS(completeData, file = "code_and_models/imputed_data.RDS")
  
  completeData
}

# Function to preprocess data
preprocess_data <- function(data) {
  # Factorize specific numeric columns
  data$x225 <- ifelse(data$x225 > 20, 21,
                      ifelse(data$x225 > 15 & data$x225 <= 20, 16,
                             ifelse(data$x225 > 10 & data$x225 <= 15, 11, data$x225)))
  data$x225 <- as.factor(data$x225)
  data$x225 <- dplyr::recode(data$x225, '11' = 'gt10', '16' = 'gt15', '21' = 'gt20')

  # Convert other columns to factors as needed
  factor_vars <- c("x025", "x023", "x245", "x246", "x302", "x022", "x227", "x249", "x226", "x228", "x046", "x244", "x155", "x287")
  for (var in factor_vars) {
    data[[var]] <- as.factor(data[[var]])
  }

  data
}

# Function to select relevant variables
select_variables <- function(data) {
  numericVarNames <- c('x235', 'x005', 'x236', 'x237', 'x014')
  DFnumeric <- data[, names(data) %in% numericVarNames]
  factorVarNames <- c('x022', 'x023', 'x046', 'x226', 'x244', 'x249', 'x287', 'x302')
  DFfactors <- data[, names(data) %in% factorVarNames]
  
  cat('There are', length(DFnumeric), 'numeric variables, and', length(DFfactors), 'factor variables')
  
  list(DFnumeric = DFnumeric, DFfactors = DFfactors)
}

# Function to remove skewness
remove_skewness <- function(data) {
  Math.cbrt <- function(x) {
    sign(x) * abs(x)^(1/3)
  }
  
  for (i in 1:ncol(data)) {
    if (abs(skew(data[, i])) > 0.8) {
      data[, i] <- Math.cbrt(data[, i])
    }
  }
  
  data
}

# Function to normalize numeric data
normalize_data <- function(data) {
  PreNum <- preProcess(data, method = c("center", "scale"))
  predict(PreNum, data)
}

# Function for one-hot encoding of factor variables
one_hot_encode <- function(data) {
  DFdummies <- as.data.frame(model.matrix(~.-1, data))
  cbind(data, DFdummies)
}

# Function for feature selection with Boruta
feature_selection <- function(data, target_var) {
  boruta_train <- Boruta(y ~ ., data = data)
  boruta_var <- getSelectedAttributes(boruta_train, withTentative = FALSE)
  selected_vars <- c(boruta_var, target_var)
  
  # Save Boruta variables
  saveRDS(selected_vars, file = "code_and_models/boruta_variables.RDS")
  
  data[, selected_vars]
}

# Function to find and save high correlations
find_and_save_high_correlations <- function(data) {
  corMatrix <- cor(data)
  highCorr <- findCorrelation(corMatrix, cutoff = 0.75)
  
  # Save high correlations
  saveRDS(highCorr, file = "code_and_models/CorHigh1.RDS")
  
  highCorr
}

# Function for hyperparameter tuning with cross-validation
hyperparameter_tuning <- function(trainX, trainY) {
  # Lasso hyperparameter tuning
  lasso_grid <- expand.grid(lambda = seq(0.001, 0.1, by = 0.0005))
  lasso_mod <- glmnet::cv.glmnet(x = as.matrix(trainX), y = trainY, alpha = 1, lambda = lasso_grid$lambda)
  best_lambda_lasso <- lasso_mod$lambda.min
  
  # XGBoost hyperparameter tuning
  xgb_grid <- list(max_depth = c(3, 5, 7), eta = c(0.01, 0.05, 0.1), nrounds = 100)
  xgb_mod <- caret::train(x = as.matrix(trainX), y = trainY, method = "xgbTree", tuneGrid = xgb_grid)
  best_params_xgb <- xgb_mod$bestTune
  
  list(lasso_lambda = best_lambda_lasso, xgb_params = best_params_xgb)
}

# Function for Chi-square test
chi_square_analysis <- function(data) {
  chisq_test <- apply(data, 2, function(x) chisq.test(x, data$y)$p.value)
  significant_vars <- names(chisq_test)[which(chisq_test < 0.05)]
  
  significant_vars
}

# Function to train and save models
train_and_save_models <- function(trainX, trainY, testX, testY) {
  # Train Lasso Model
  lasso_mod <- glmnet::cv.glmnet(x = as.matrix(trainX), y = trainY, alpha = 1, lambda = seq(0.001, 0.1, by = 0.0005))
  lasso_pred <- predict(lasso_mod, newx = as.matrix(testX), s = lasso_mod$lambda.min)
  
  # Train XGBoost Model
  xgb_mod <- xgboost::xgboost(data = as.matrix(trainX), label = trainY, max_depth = 3, eta = 0.05, nrounds = 500, objective = "reg:linear")
  xgb_pred <- predict(xgb_mod, as.matrix(testX))
  
  # Train Random Forest Model
  rf_mod <- randomForest::randomForest(y ~ ., data = cbind(trainX, y = trainY), ntree = 500, mtry = 6)
  rf_pred <- predict(rf_mod, newdata = testX)
  
  # Save models
  saveRDS(lasso_mod, file = "code_and_models/lasso_model.rds")
  saveRDS(xgb_mod, file = "code_and_models/xgboost_model.rds")
  saveRDS(rf_mod, file = "code_and_models/random_forest_model.rds")
  
  list(lasso_pred = lasso_pred, xgb_pred = xgb_pred, rf_pred = rf_pred)
}

# Function to create voting ensemble of models
voting_ensemble <- function(preds_list) {
  # Simple average
  avg_pred <- rowMeans(preds_list)
  
  # Top 2 average
  top2_avg_pred <- rowMeans(preds_list[, order(colSums(preds_list), decreasing = TRUE)[1:2]])
  
  list(avg_pred = avg_pred, top2_avg_pred = top2_avg_pred)
}

# Main script execution
file_path <- "dataset_03_with_header.csv"
raw_data <- load_data(file_path)
analyze_data(raw_data)

# Handle missing data
vars_to_keep <- c("x235", "x005", "x236", "x237", "x014", "x022", "x023", "x046", "x226", "x244", "x249", "x287", "x302")
complete_data <- handle_missing_data(raw_data, vars_to_keep)

# Preprocess data
processed_data <- preprocess_data(complete_data)

# Select relevant variables
selected_vars <- select_variables(processed_data)
DFnumeric <- selected_vars$DFnumeric
DFfactors <- selected_vars$DF

# Remove skewness from numeric variables
DFnumeric <- remove_skewness(DFnumeric)

# Normalize numeric data
DFnumeric_norm <- normalize_data(DFnumeric)

# One-hot encode factor variables
combined <- one_hot_encode(DFfactors)

# Combine processed numeric and encoded data
processed_data <- cbind(DFnumeric_norm, combined)

# Feature selection using Boruta or any other method
target_var <- "y"  # Assuming "y" is the target variable
selected_data <- feature_selection(processed_data, target_var)

# Find and save high correlations
high_correlations <- find_and_save_high_correlations(selected_data)

# Split data into training and testing sets
set.seed(123)  # Set seed for reproducibility
train_idx <- sample(1:nrow(selected_data), 0.8 * nrow(selected_data))  # 80% train, 20% test
train_data <- selected_data[train_idx, ]
test_data <- selected_data[-train_idx, ]

# Perform hyperparameter tuning
hyperparams <- hyperparameter_tuning(train_data[, -which(names(train_data) == "y")], train_data$y)

# Train models and make predictions
predictions <- train_and_save_models(train_data[, -which(names(train_data) == "y")], train_data$y,
                                     test_data[, -which(names(test_data) == "y")], test_data$y)

# Perform Chi-square analysis
significant_vars <- chi_square_analysis(selected_data)

# Create voting ensemble of models
preds_list <- list(predictions$lasso_pred, predictions$xgb_pred, predictions$rf_pred)
voting_results <- voting_ensemble(preds_list)

# Print or use results as needed
print(voting_results)
