# Load libraries
library(mlflow)
library(Metrics) # For calculating RMSE
library(caret)
library(MASS) # For Boston dataset
library(glue)

#' Compute monitoring RMSE for a model
#'
#' @param model_name character, name of the model
#' @param alias character, alias of the model version
#' @param new_data dataframe, new data for validation
#' @param target_column character, name of the target column
#' @return NULL
compute_monitoring_rmse <- function(model_name, alias = "champion", new_data, target_column) {
  # Check for required parameters
  if (is.null(model_name) || is.null(new_data) || is.null(target_column)) {
    stop("model_name, new_data, and target_column are required parameters")
  }

  mlflow_run <- NULL
  tryCatch(
    {
      mlflow_run <- mlflow_start_run()

      cat("Loading model and computing monitoring RMSE...\n")

      # Try to load the model from MLflow
      model <- tryCatch(
        {
          mlflow_load_model(glue("models:/{model_name}@{alias}"))
        },
        error = function(e) {
          if (grepl("RESOURCE_DOES_NOT_EXIST", e$message)) {
            stop(glue("Model '{model_name}' with alias '{alias}' does not exist in MLflow. Please check the model name and alias."))
          } else {
            stop(glue("Error loading model: {e$message}"))
          }
        }
      )

      # Validate input data
      if (!target_column %in% colnames(new_data)) {
        stop(paste("The new data does not have the specified target column:", target_column))
      }

      # Separate features and target
      features <- new_data[, !(colnames(new_data) %in% target_column)]
      actuals <- new_data[[target_column]]

      # Make predictions
      predictions <- model(features)

      # Calculate RMSE
      rmse_value <- rmse(actuals, predictions)

      # Log the RMSE to MLflow
      mlflow_log_metric("monitoring_rmse", rmse_value)

      cat("Monitoring RMSE:", rmse_value, "\n")

      mlflow_end_run(status = "FINISHED")
      cat("Model validation and RMSE logging completed successfully.\n")
    },
    error = function(e) {
      cat("Error during model validation:", e$message, "\n")
      if (!is.null(mlflow_run)) {
        mlflow_end_run(status = "FAILED")
      }
      stop(e$message)  # Re-throw the error to ensure it's not silently caught
    }
  )
}

#' Test the compute_monitoring_rmse function
#'
#' @return NULL
test_compute_monitoring_rmse <- function() {
  # Example usage of monitoring function with the Boston Housing dataset
  data("Boston")
  new_data <- Boston[1:20, ] # Assuming this represents new data for monitoring

  compute_monitoring_rmse(
    model_name = "Boston_Housing_MLR_Model",
    new_data = new_data,
    target_column = "medv"
  )
}
