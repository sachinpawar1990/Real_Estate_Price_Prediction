# Load functions from separate script
source("functions.R")

# Suppress warnings and messages
suppressMessages(load_libraries())

# Set seed for reproducibility
set.seed(123)

# Load test data
test_data <- load_test_data("input_data/test.csv")

# Load required files and objects
source("code_and_models/mice.reuse.R")
CorHigh <- readRDS("code_and_models/CorHigh1.RDS")
imputed_Data <- readRDS("code_and_models/imputed_data.RDS")
boruta_var <- readRDS("code_and_models/boruta_variables.RDS")
lasso_mod <- readRDS("code_and_models/lasso_model.RDS")
xgb_mod <- readRDS("code_and_models/xgboost_model.RDS")
rf_model <- readRDS("code_and_models/random_forest_model.RDS")

# Select only high correlated variables
test_data <- test_data[, names(test_data) %in% CorHigh]
test_data2 <- test_data[, !names(test_data) %in% "y"]

# Imputation of data
imp_test <- impute_data(imputed_Data, test_data2)

# Select required columns
sel_test <- imp_test[[1]] %>% select(c("x235", "x005", "x236", "x237", "x014", "x022", "x023", "x046", "x226", "x244", "x249", "x287", "x302"))

# Factorize numeric columns with levels
sel_test$x022 <- as.factor(sel_test$x022)
sel_test$x023 <- as.factor(sel_test$x023)
sel_test$x046 <- ifelse(sel_test$x046 > 20, 21, ifelse(sel_test$x046 > 15 & sel_test$x046 <= 20, 16, ifelse(sel_test$x046 > 10 & sel_test$x046 <= 15, 11, sel_test$x046)))
sel_test$x046 <- as.factor(sel_test$x046)
sel_test$x046 <- suppressMessages(suppressWarnings(revalue(sel_test$x046, c('11' = 'gt10', '16' = 'gt15', '21' = 'gt20'))))
sel_test$x226 <- ifelse(sel_test$x226 > 20, 21, ifelse(sel_test$x226 > 15 & sel_test$x226 <= 20, 16, sel_test$x226))
sel_test$x226 <- as.factor(sel_test$x226)
sel_test$x226 <- suppressMessages(suppressWarnings(revalue(sel_test$x226, c('16' = 'gt15', '21' = 'gt20'))))
sel_test$x244 <- as.factor(sel_test$x244)
sel_test$x249 <- as.factor(sel_test$x249)
sel_test$x287 <- as.factor(sel_test$x287)
sel_test$x302 <- as.factor(sel_test$x302)

# Define numeric and factor variables
numericVarNames <- c('x235', 'x005', 'x236', 'x237', 'x014')
DFnumeric <- sel_test[, names(sel_test) %in% numericVarNames]
factorVarNames <- c('x022', 'x023', 'x046', 'x226', 'x244', 'x249', 'x287', 'x302')
DFfactors <- sel_test[, names(sel_test) %in% factorVarNames]

# Remove skewness and normalize numeric data
DFnorm <- preprocess_numeric(DFnumeric)

# One hot encoding for factor variables
DFdummies <- one_hot_encode(DFfactors)
combined <- cbind(DFnorm, DFdummies, y = test_data$y)

# Select variables selected with Boruta
combined <- combined[, names(combined) %in% c(boruta_var, "y")]
testX <- combined[, -which(names(combined) %in% "y")]

# Create dummy columns for variables not found in test data
diff_col <- setdiff(boruta_var, names(testX))
empty_df <- data.frame(matrix(0, ncol = length(diff_col), nrow = nrow(testX)))
names(empty_df) <- diff_col
testX <- cbind(testX, empty_df)

# Order feature names as per XGBoost model feature names
col_order <- xgb_mod$feature_names
testX <- testX[, col_order]

# Predictions
results <- data.frame(combined)
results$LassoPred <- predict_lasso(lasso_mod, testX)
results$XGBPred <- predict_xgboost(xgb_mod, testX)
results$rfpred <- predict_random_forest(rf_model, testX)

# Evaluate and print model metrics
results <- evaluate_model(results)

# Write results to CSV file
write_results_to_csv(results, "output_data/results.csv")

# Print statement indicating end of prediction
cat("Prediction Finished !!!\n")
