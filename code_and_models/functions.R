# Load libraries with suppressMessages and suppressWarnings
load_libraries <- function() {
  library(plyr)
  library(dplyr)
  library(Metrics)
  library(xgboost)
  library(randomForest)
  library(mice)
  library(glmnet)
  library(caret)
  library(psych)
}

# Load test data
load_test_data <- function(file_path) {
  read.csv(file_path, stringsAsFactors = FALSE)
}

# Imputation function using mice.reuse
impute_data <- function(imputed_Data, test_data, maxit = 5) {
  suppressMessages(suppressWarnings(mice.reuse(imputed_Data, test_data, maxit = maxit)))
}

# Preprocess numeric data (remove skewness and normalize)
preprocess_numeric <- function(DFnumeric) {
  for (i in 1:ncol(DFnumeric)) {
    if (abs(skew(DFnumeric[, i])) > 0.8) {
      DFnumeric[, i] <- sign(DFnumeric[, i]) * abs(DFnumeric[, i])^(1/3)
    }
  }
  PreNum <- preProcess(DFnumeric, method = c("center", "scale"))
  predict(PreNum, DFnumeric)
}

# One hot encoding for factor variables
one_hot_encode <- function(DFfactors) {
  as.data.frame(model.matrix(~.-1, DFfactors))
}

# Predict using Lasso model
predict_lasso <- function(lasso_mod, testX) {
  predict(lasso_mod, testX)
}

# Predict using XGBoost model
predict_xgboost <- function(xgb_mod, testX) {
  dtest <- xgb.DMatrix(data = as.matrix(testX))
  predict(xgb_mod, dtest)
}

# Predict using Random Forest model
predict_random_forest <- function(rf_model, testX) {
  predict(rf_model, testX)
}

# Evaluate model and generate results
evaluate_model <- function(results) {
  results$LassoPred <- round(results$LassoPred)
  results$XGBPred <- round(results$XGBPred)
  results$rfpred <- round(results$rfpred)
  
  results$avg_pred2 <- round((results$XGBPred + results$rfpred) / 2)
  results$avgAE2 <- abs(results$y - round(results$avg_pred2))
  
  results_acc <- subset(results, results$avgAE2 <= 3)
  
  rmse_val <- rmse(results$y, results$avg_pred2)
  mae_val <- mae(results$y, results$avg_pred2)
  mape_val <- mape(results$y, results$avg_pred2)
  accuracy_val <- nrow(results_acc) * 100 / nrow(results)
  
  cat("RMSE of the model is ", round(rmse_val, 2), "\n")
  cat("MAE of the model is ", round(mae_val, 2), "\n")
  cat("MAPE of the model is ", round(mape_val, 2), "\n")
  cat("Accuracy of the model is ", round(accuracy_val, 2), "% if abs(error) > 3 is incorrect and abs(error) <= 3 is correct\n")
  
  return(results)
}

# Write results to CSV file
write_results_to_csv <- function(results, file_path) {
  write.csv(results, file_path)
}
