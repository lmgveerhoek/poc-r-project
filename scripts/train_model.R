library(mlflow)
library(caret)
library(Metrics) # For calculating RMSE
library(MASS) # For Boston dataset
library(carrier) # For wrapping the model

# Function to train a linear regression model
train_model <- function(data, model_name = "Trained_Model", artifact_path = "Model_Artifact") {
  cat("Training model with the provided data...\n")

  # Hardcoded target column and model method
  target_column <- "medv"
  model_method <- "lm"

  # Ensure data contains the target column
  if (!target_column %in% colnames(data)) {
    stop(paste("The data does not contain the specified target column:", target_column))
  }

  # Handle missing values by imputing with median values
  for (variable in colnames(data)) {
    data[[variable]][is.na(data[[variable]])] <- median(data[[variable]], na.rm = TRUE)
  }

  # Split the dataset into training and testing sets
  set.seed(123)
  training_indices <- createDataPartition(data[[target_column]], p = 0.8, list = FALSE)
  training_data <- data[training_indices, ]
  testing_data <- data[-training_indices, ]

  # Train the multiple linear regression model
  formula <- as.formula(paste(target_column, "~ ."))
  model <- train(formula, data = training_data, method = model_method)

  # Wrap the model using `crate()`
  fn <- crate(~ caret::predict.train(model, .x), model = model)

  # Define mlflow_run variable outside tryCatch to access it in error handling
  mlflow_run <- NULL

  # Wrap all actions in a tryCatch to handle errors
  tryCatch(
    {
      # Start MLflow run
      mlflow_run <- mlflow_start_run()

      # Log the wrapped model to MLflow
      mlflow_log_model(model = fn, artifact_path = artifact_path)

      # Make predictions on the test set
      predictions <- predict(model, newdata = testing_data)

      # Calculate and log metrics
      actuals <- testing_data[[target_column]]
      mae_value <- mean(abs(predictions - actuals))
      mse_value <- mean((predictions - actuals)^2)
      rmse_value <- sqrt(mse_value)

      mlflow_log_metric("MAE", mae_value)
      mlflow_log_metric("MSE", mse_value)
      mlflow_log_metric("RMSE", rmse_value)

      # Print metrics to console
      cat("Mean Absolute Error (MAE):", mae_value, "\n")
      cat("Mean Squared Error (MSE):", mse_value, "\n")
      cat("Root Mean Squared Error (RMSE):", rmse_value, "\n")

      # End MLflow run successfully
      mlflow_end_run(run_id = mlflow_run$run_uuid, status = "FINISHED")
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

# Test the training function with Boston Housing dataset
test_train_model <- function() {
  # Load the Boston Housing dataset
  data("Boston")
  
  # Example usage of training function
  train_model(data = Boston, model_name = "Boston_Housing_MLR_Model", artifact_path = "Boston_Housing_MLR_Artifact")
}