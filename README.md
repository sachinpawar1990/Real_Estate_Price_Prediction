# Real_Estate_Price_Prediction
This project builds a machine learning model to predict house selling prices aiming to empower informed decisions for buyers, sellers, and real estate professionals.

Overview:
This project aims to develop a machine learning model capable of predicting the selling price of houses. The model is trained on historical data containing information about houses and their corresponding selling prices. The predicted prices are the numeric values falling within a predefined range that reflects the typical house prices in the target region.

Objective:

The primary objective of this project is to create a reliable tool that can estimate the selling price of a house based on its characteristics and market trends. This information can be valuable for various stakeholders in the real estate market, including:

Homeowners: Get a more informed estimate of their property's potential selling price.
Potential buyers: Gain insights into the fair market value of houses they are considering purchasing.
Real estate agents: Enhance their ability to price houses competitively and provide data-driven recommendations to their clients.
Investors: Develop data-driven strategies for property selection and valuation.
By providing accurate and timely price predictions, this model can contribute to increased transparency and efficiency within the real estate market.


1. train_model.R – This R script contains the logic used while training the model and other data exploration.
2. Dockerfile – This file contains Docker commands to build the docker image and run the container.
3. input_data – This directory should have the test data for which prediction model is to be tested. File should be of CSV format and should contain 305 columns, x001 to x304 along with y.
4. output_data – This directory would have results of the prediction model after it has been executed. It would be in the CSV format (results.csv). It would contain predictions of each of the algorithms and its absolute errors. “avg_pred2” is the prediction of final model and “avgAE2” is the absolute error of that model.
5. code_and_models – This directory contains the R script to test the prediction model, other R objects and saved models to be used in prediction purpose.
run_prediction.R – R Script to do the prediction on test set.
mice.reuse.R – R Script to do the imputation of missing values
install_packages.R – R Script which is used to install R packages while building the Docker image.
CorHigh1.RDS – R object which contains the correlated variables taken from training data
random_forest_model.RDS – saved Random Forest Model built from training data set
xgboost_model.RDS – saved xgboost Model built from training data set
lasso_model.RDS - saved lasso Model built from training data set
boruta_variables.RDS – saved features selected from Boruta feature Selection method from training set
imputed_data.RDS – R object which is used to do imputation of missing values
