# Base image https://hub.docker.com/u/rocker/
FROM rocker/r-base:latest
## create directories
RUN mkdir -p /input_data
RUN mkdir -p /code_and_models
RUN mkdir -p /output_data
## copy files
COPY /code_and_models/install_packages.R /code_and_models/install_packages.R
COPY /code_and_models/run_prediction.R /code_and_models/run_prediction.R
COPY /code_and_models/boruta_variables.RDS /code_and_models/boruta_variables.RDS
COPY /code_and_models/CorHigh1.RDS /code_and_models/CorHigh1.RDS
COPY /code_and_models/imputed_data.RDS /code_and_models/imputed_data.RDS
COPY /code_and_models/lasso_model.RDS /code_and_models/lasso_model.RDS
COPY /code_and_models/mice.reuse.R /code_and_models/mice.reuse.R
COPY /code_and_models/random_forest_model.RDS /code_and_models/random_forest_model.RDS
COPY /code_and_models/xgboost_model.RDS /code_and_models/xgboost_model.RDS
## install R-packages
RUN Rscript /code_and_models/install_packages.R
## run the script
CMD Rscript /code_and_models/run_prediction.R