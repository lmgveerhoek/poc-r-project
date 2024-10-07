library(mlflow)
library(dotenv)
library(bigrquery)
library(glue)

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

# Authenticate with BigQuery
# If GOOGLE_APPLICATION_CREDENTIALS is set, use it for authentication; otherwise, use interactive OAuth
credentials_path <- Sys.getenv("GOOGLE_APPLICATION_CREDENTIALS")
if (credentials_path != "") {
  bq_auth(path = credentials_path)
} else {
  bq_auth()  # Will open a browser for OAuth authentication
}

# Set project ID from environment variable
project_id <- Sys.getenv("GOOGLE_PROJECT_ID")
if (project_id == "") {
  stop("Error: GOOGLE_PROJECT_ID environment variable is not set. Please set it in your .env file or environment.")
}

# Construct the SQL query to retrieve data from the last year
query <- glue(
  "
  SELECT *
  FROM `{project_id}.dataset_energiebespaarders.test_table`
  WHERE intake_date >= DATETIME_SUB(CURRENT_DATETIME(), INTERVAL 1 YEAR)
  "
)

# Run the query
result <- bq_project_query(project_id, query)

# Download the query results into an R dataframe
data <- bq_table_download(result, quiet = FALSE)

# Print the data
print(data)

set_mlflow_tracking_uri()