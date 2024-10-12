# Load libraries
library(mlflow)
library(Metrics) # For calculating RMSE
library(caret)
library(MASS) # For Boston dataset
library(glue)

# Function to compute monitoring RMSE
compute_monitoring_rmse <- function(model_name, alias = "champion", new_data, target_column) {
  # Define mlflow_run variable outside tryCatch to access it in error handling
  mlflow_run <- NULL

  # Wrap all actions in a tryCatch to handle errors
  tryCatch(
    {
      # Start an MLflow run for logging the monitoring metrics
      mlflow_run <- mlflow_start_run()

      # Load the model from MLflow
      model <- mlflow_load_model(glue("models:/{model_name}@{alias}"))

      # Ensure the new_data contains the target column for RMSE calculation
      if (!target_column %in% colnames(new_data)) {
        stop(paste("The new data does not have the specified target column:", target_column))
      }

      # Separate the features and target
      features <- new_data[, !(colnames(new_data) %in% target_column)]
      actuals <- new_data[[target_column]]

      # Make predictions using the loaded model
      predictions <- model(features)

      # Calculate RMSE
      rmse_value <- rmse(actuals, predictions)

      # Log the RMSE to MLflow
      mlflow_log_metric("monitoring_rmse", rmse_value)

      # End MLflow run successfully
      mlflow_end_run(run_id = mlflow_run$run_uuid, status = "FINISHED")

      # Print RMSE
      cat("Monitoring RMSE:", rmse_value, "\n")
    },
    error = function(e) {
      # End MLflow run with failed status if mlflow_run has been started
      if (!is.null(mlflow_run)) {
        mlflow_end_run(run_id = mlflow_run$run_uuid, status = "FAILED")
      }
      cat("An error occurred:", e$message, "\n")
    }
  )
}

test_compute_monitoring_rmse <- function() {
  # Example usage of monitoring function with the Boston Housing dataset
  # Load new dataset (for demonstration purposes, we'll use a subset of Boston)
  data("Boston")
  new_data <- Boston[1:20, ] # Assuming this represents new data for monitoring

  # Compute and log monitoring RMSE for the Boston Housing model
  compute_monitoring_rmse(
    model_name = "BostonModel",
    new_data = new_data,
    target_column = "medv"
  )
}
