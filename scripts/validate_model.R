# Function to simulate validating a linear regression model
validate_model <- function(data) {
  cat("Validating model with the provided data...\n")
  # Simulated validation logic (replace with actual model validation)
  Sys.sleep(2)
  cat("Model validation complete.\n")
}

evaluate_model <- function(data) {
  # Load the latest model version in the Production stage
  model <- mlflow_load_model("models:/BestLinearModel/Production")

  # Prepare data (assuming the target column is named "target")
  X <- data[, !(names(data) %in% c("target"))]
  y_true <- data$target

  # Make predictions using the loaded model
  y_pred <- predict(model, newdata = X)

  # Calculate RMSE
  rmse_value <- rmse(y_true, y_pred)

  # Log the evaluation metrics to MLflow
  mlflow_start_run()
  mlflow_log_metric("monitoring_rmse", rmse_value)
  mlflow_end_run()

  # Print RMSE to console
  print(paste("RMSE:", rmse_value))
}
