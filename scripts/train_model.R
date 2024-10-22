library(mlflow)
library(caret)
library(Metrics) # For calculating RMSE
library(MASS) # For Boston dataset
library(carrier) # For wrapping the model
library(glue)

#' Train a linear regression model and log it with MLflow
#'
#' @param data dataframe, input data for training
#' @param model_name character, name of the model
#' @param artifact_path character, path to save model artifacts
#' @param target_column character, name of the target column
#' @return NULL
train_model <- function(data, model_name = "Trained_Model", artifact_path = "Model_Artifact", target_column) {
  # Check for required parameters
  if (is.null(data) || is.null(target_column)) {
    stop("data and target_column are required parameters")
  }

  mlflow_run <- NULL
  nan_encountered <- FALSE  # Flag to track if NaN values were encountered

  tryCatch(
    {
      mlflow_run <- mlflow_start_run()

      cat("Training model with the provided data...\n")

      data <- handle_missing_values(data)

      # Split the dataset into training and testing sets
      set.seed(123)
      training_indices <- createDataPartition(data[[target_column]], p = 0.8, list = FALSE)
      training_data <- data[training_indices, ]
      testing_data <- data[-training_indices, ]

      # Train the multiple linear regression model
      formula <- as.formula(paste(target_column, "~ ."))
      model <- train(formula, data = training_data, method = "lm")

      # Wrap the model using `crate()`
      wrapped_model <- crate(~ caret::predict.train(model, .x), model = model)

      # Log the model
      mlflow_log_model(model = wrapped_model, artifact_path = artifact_path)

      # Calculate and log metrics
      predictions <- predict(model, newdata = testing_data)
      actuals <- testing_data[[target_column]]

      metrics <- list(
        MAE = mean(abs(predictions - actuals), na.rm = TRUE),
        MSE = mean((predictions - actuals)^2, na.rm = TRUE),
        RMSE = sqrt(mean((predictions - actuals)^2, na.rm = TRUE))
      )

      for (metric_name in names(metrics)) {
        if (is.nan(metrics[[metric_name]])) {
          cat(glue("Warning: {metric_name} is NaN. Check your data and model.\n"))
          nan_encountered <- TRUE
        } else {
          mlflow_log_metric(metric_name, metrics[[metric_name]])
          cat(glue("{metric_name}: {metrics[[metric_name]]}\n"))
        }
      }

      mlflow_end_run(status = if(nan_encountered) "FAILED" else "FINISHED")
      
      if (nan_encountered) {
        cat("Model training completed, but NaN values were encountered in metrics. Please review your data and model.\n")
      } else {
        cat("Model training and logging completed successfully.\n")
      }
    },
    error = function(e) {
      cat(glue("An error occurred during model training: {e$message}\n"))
      if (!is.null(mlflow_run)) {
        mlflow_end_run(status = "FAILED")
      }
    }
  )
}

#' Handle missing values in the data
#'
#' @param data dataframe, input data
#' @return dataframe with missing values imputed
handle_missing_values <- function(data) {
  for (variable in colnames(data)) {
    data[[variable]][is.na(data[[variable]])] <- median(data[[variable]], na.rm = TRUE)
  }
  data
}

#' Test the training function with Boston Housing dataset
#'
#' @return NULL
test_train_model <- function() {
  data("Boston")
  train_model(
    data = Boston, model_name = "Boston_Housing_MLR_Model",
    artifact_path = "Boston_Housing_MLR_Artifact", target_column = "medv"
  )
}
