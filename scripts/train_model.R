# Function to simulate training a linear regression model
train_model <- function(data) {
  cat("Training model with the provided data...\n")

  # Load the Boston Housing dataset
  data("Boston")

  # Exploratory Data Analysis (EDA)
  # summary(Boston)

  # Handle missing values by imputing with median values
  for (variable in colnames(Boston)) {
    Boston[[variable]][is.na(Boston[[variable]])] <- median(Boston[[variable]], na.rm = TRUE)
  }

  # Split the dataset into training and testing sets
  set.seed(123)
  training_indices <- createDataPartition(Boston$medv, p = 0.8, list = FALSE)
  training_data <- Boston[training_indices, ]
  testing_data <- Boston[-training_indices, ]

  # Train the multiple linear regression model
  model <- train(medv ~ ., data = training_data, method = "lm")

  # Wrap the model using `crate()`
  fn <- crate(~ caret::predict.train(model, .x), model = model)

  # Wrap all actions in a tryCatch to handle errors
  tryCatch(
    {
      # Start MLflow run
      with(mlflow_start_run(), {
        # Log the wrapped model to MLflow
        mlflow_log_model(model = fn, artifact_path = "Boston_Housing_MLR_Model")

        # Make predictions on the test set
        predictions <- predict(model, newdata = testing_data)

        # Calculate and log metrics
        mae_value <- mean(abs(predictions - testing_data$medv))
        mse_value <- mean((predictions - testing_data$medv)^2)
        rmse_value <- sqrt(mse_value)

        mlflow_log_metric("MAE", mae_value)
        mlflow_log_metric("MSE", mse_value)
        mlflow_log_metric("RMSE", rmse_value)

        # Print metrics to console
        cat("Mean Absolute Error (MAE):", mae_value, "\n")
        cat("Mean Squared Error (MSE):", mse_value, "\n")
        cat("Root Mean Squared Error (RMSE):", rmse_value, "\n")
      })
    },
    error = function(e) {
      cat("An error occurred:", e$message, "\n")
    }
  )
}
