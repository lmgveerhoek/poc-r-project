library(mlflow)
library(dotenv)

# Load .env 
load_dot_env(file = ".env")

# Function: Retrieves the MLFlow URI from the environment
# within a local scope to reduce the risk of exposing the URI
set_mlflow_tracking_uri <- function() {
  # Retrieve the MLFlow URI from the environment
  tracking_uri <- Sys.getenv("MLFLOW_TRACKING_URI")
  cat("MLflow tracking uri set to:", tracking_uri, "\n")

  # Set the MLFlow URI
  client <- mlflow_client(tracking_uri)

  # Return the client
  return(client)
}

set_mlflow_tracking_uri()