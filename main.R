library(mlflow)
library(dotenv)
library(bigrquery)
library(glue)
library(optparse)

# Source the training and validation functions
cat("Sourcing training and validation functions...\n")
source("scripts/train_model.R")
source("scripts/validate_model.R")

# Load environment variables from .env file
load_dot_env(file = ".env")

# Set MLflow tracking URI
mlflow_set_tracking_uri(Sys.getenv("MLFLOW_TRACKING_URI"))
client <- mlflow_client()

# Parse command line arguments
option_list <- list(
  make_option(c("-m", "--mode"),
    type = "character", default = "validate",
    help = "Mode of operation: 'train' or 'validate'", metavar = "character"
  ),
  make_option(c("-s", "--source"),
    type = "character", default = "bigquery",
    help = "Data source: 'bigquery' or 'csv'", metavar = "character"
  ),
  make_option(c("-f", "--file"),
    type = "character", default = "data/sample_data.csv",
    help = "CSV file path (used if source is 'csv')", metavar = "character"
  ),
  make_option(c("-q", "--query"),
    type = "character",
    help = "SQL query to run against BigQuery (optional)", metavar = "character"
  )
)

opt_parser <- OptionParser(option_list = option_list)
opt <- parse_args(opt_parser)

# Check if running in interactive mode, if so, use default values
if (interactive()) {
  # Set default values for RStudio/development
  opt <- list(
    mode = "validate",
    source = "csv",
    file = "data/sample_data.csv"
  )
  cat("Detected interactive mode. Using default values for development.\n")
} else {
  # Parse arguments for production use
  opt <- parse_args(opt_parser)
}

# Load data based on the source parameter
switch(opt$source,
  # Load data from BigQuery
  bigquery = {
    # Authenticate with BigQuery
    credentials_path <- Sys.getenv("GOOGLE_APPLICATION_CREDENTIALS")
    if (credentials_path != "") {
      bq_auth(path = credentials_path)
    } else {
      bq_auth() # Will open a browser for OAuth authentication
    }

    # Set project ID from environment variable
    project_id <- Sys.getenv("GOOGLE_PROJECT_ID")
    if (project_id == "") {
      stop("Error: GOOGLE_PROJECT_ID environment variable is not set. Please set it in your .env file or environment.")
    }

    # Use the provided query if available, otherwise use the default one
    query <- if (!is.null(opt$query)) {
      opt$query
    } else {
      glue("
          SELECT *
          FROM `{project_id}.dataset_energiebespaarders.test_table`
          WHERE intake_date >= DATETIME_SUB(CURRENT_DATETIME(), INTERVAL 1 YEAR)
          ")
    }

    # Run the query and download the results into an R dataframe
    result <- bq_project_query(project_id, query)
    data <- bq_table_download(result, quiet = TRUE)
  },
  # Load data from CSV
  csv = {
    if (!is.null(opt$file)) {
      # Load data from CSV file
      data <- read.csv(opt$file)
    } else {
      stop("CSV file not specified. Use '--file' option to provide a valid CSV file.")
    }
  },
  stop("Invalid data source provided. Use 'bigquery' or 'csv'.")
)

# Print the data
print(data)

# Execute based on the mode parameter
switch(opt$mode,
  train = {
    train_model(data)
  },
  validate = {
    validate_model(data)
  },
  stop("Invalid mode provided. Use 'train' or 'validate'.")
)
