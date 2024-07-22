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

Files Included:
1. train_model.R – This R script contains the logic used while training the model and other data exploration.
2. Dockerfile – This file contains Docker commands to build the docker image and run the container.
3. input_data – This directory should have the test data for which prediction model is to be tested. File should be of CSV format and should contain 305 columns, x001 to x304 along with y.
4. output_data – This directory would have results of the prediction model after it has been executed. It would be in the CSV format (results.csv). It would contain predictions of each of the algorithms and its absolute errors. “avg_pred2” is the prediction of final model and “avgAE2” is the absolute error of that model.
5. code_and_models – This directory contains the R script to test the prediction model, other R objects and saved models to be used in prediction purpose.
i. run_prediction.R – R Script to do the prediction on test set.
ii. mice.reuse.R – R Script to do the imputation of missing values
iii. install_packages.R – R Script which is used to install R packages while building the Docker image.
iv. CorHigh1.RDS – R object which contains the correlated variables taken from training data
v. random_forest_model.RDS – saved Random Forest Model built from training data set
vi. xgboost_model.RDS – saved xgboost Model built from training data set
vii. lasso_model.RDS - saved lasso Model built from training data set
viii. boruta_variables.RDS – saved features selected from Boruta feature Selection method from training set
ix. imputed_data.RDS – R object which is used to do imputation of missing values


Steps to run:

Note: Following steps are stated for Windows environment. Should work for Linux after making small changes.
1. First unzip the contents of zip file in some directory.
2. Make sure that system has application to build the Docker images like Docker Desktop. Also, make sure that system is connected to internet to pull the Docker image.
3. In that directory, open the command prompt (I have used Windows Powershell). Change the directory to the directory in which zip file was extracted and contains Dockerfile.
4. Run the command “docker build -t estate_prediction_img .”. It would build the docker image. It would run for a while (for me, it took almost 16 minutes to build image). Here, estate_prediction_img is the name I have given to Docker image.
5. Change the paths highlighted as per the system in the command:
   C:\Real_Estate_Prediction\input_data:/input_data -v C:\Real_Estate_Prediction\output_data:/output_data estate_prediction_img
   Replace "C:\Real_Estate_Prediction" path with your own path.
6. Output would be generated as shown in the sample figure.
   Note the MAPE and Accuracy shown by the model. Please note that MAPE is not given in % but accuracy is in %.


   ![image](https://github.com/user-attachments/assets/de22ef6a-f059-4346-b6d6-cd4f3e306551)


   
