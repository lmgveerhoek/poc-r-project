# Load the required libraries
library(mlflow)
library(dotenv)
library(bigrquery)
library(glue)
library(optparse)
library(readr) # For reading CSV data
library(MASS) # For Boston dataset

# Source the training and validation functions
cat("Sourcing training and validation functions...\n")
source("scripts/train_model.R")
source("scripts/validate_model.R")

#' Set up the environment and MLflow tracking URI
#'
#' @return NULL
setup_environment <- function() {
  load_dot_env(file = ".env")
  tracking_uri <- Sys.getenv("MLFLOW_TRACKING_URI")
  if (tracking_uri == "") {
    stop("Error: MLFLOW_TRACKING_URI not set. Please set it in your .env or environment.")
  }
  mlflow_set_tracking_uri(tracking_uri)
}

#' Parse command line arguments
#'
#' @return list of parsed options
parse_arguments <- function() {
  option_list <- list(
    make_option(c("-m", "--mode"),
      type = "character", default = "validate",
      help = "Mode of operation: 'train' or 'validate'"
    ),
    make_option(c("-s", "--source"),
      type = "character", default = "bigquery",
      help = "Data source: 'bigquery' or 'csv'"
    ),
    make_option(c("-f", "--file"),
      type = "character", default = "data/sample_data.csv",
      help = "CSV file path (used if source is 'csv')"
    ),
    make_option(c("-q", "--query"),
      type = "character",
      help = "SQL query to run against BigQuery (optional)"
    ),
    make_option(c("-n", "--model_name"),
      type = "character", default = "default_model",
      help = "Name of the model"
    ),
    make_option(c("-a", "--model_alias"),
      type = "character", default = "latest",
      help = "Alias for the model (for verification)"
    ),
    make_option(c("-t", "--target_column"),
      type = "character", default = "medv",
      help = "Name of the target column"
    )
  )

  if (interactive()) {
    list(
      mode = "train", 
      source = "csv", 
      file = "data/sample_data.csv",
      model_name = "default_model",
      model_alias = "latest",
      target_column = "squared_meters"
    )
  } else {
    parse_args(OptionParser(option_list = option_list))
  }
}

#' Load data based on the specified source
#'
#' @param source character, data source ("bigquery" or "csv")
#' @param file character, path to CSV file (if applicable)
#' @param query character, SQL query for BigQuery (if applicable)
#' @return dataframe of loaded data
load_data <- function(source, file = NULL, query = NULL) {
  if (source == "bigquery") {
    load_from_bigquery(query)
  } else if (source == "csv") {
    load_from_csv(file)
  } else {
    stop("Invalid data source provided. Use 'bigquery' or 'csv'.")
  }
}

#' Load data from BigQuery
#'
#' @param query character, SQL query to run
#' @return dataframe of query results
load_from_bigquery <- function(query) {
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
    stop("Error: GOOGLE_PROJECT_ID environment variable is not set.")
  }

  # Use the provided query if available, otherwise use the default one
  if (is.null(query)) {
    query <- glue("
      SELECT *
      FROM `{project_id}.dataset_energiebespaarders.test_table`
      WHERE intake_date >= DATETIME_SUB(CURRENT_DATETIME(), INTERVAL 1 YEAR)
    ")
  }

  # Run the query and download the results
  tryCatch(
    {
      result <- bq_project_query(project_id, query)
      bq_table_download(result, quiet = TRUE)
    },
    error = function(e) {
      stop("Error running BigQuery query: ", e$message)
    }
  )
}

#' Load data from CSV file
#'
#' @param file character, path to CSV file
#' @return dataframe of CSV data
load_from_csv <- function(file) {
  if (!is.null(file) && file.exists(file)) {
    read.csv(file)
  } else {
    stop("CSV file not specified or doesn't exist. Use '--file' option to provide a valid CSV file.")
  }
}

#' Main function to run the script
#'
#' @return NULL
main <- function() {
  setup_environment()
  opt <- parse_arguments()
  data <- load_data(opt$source, opt$file, opt$query)

  if (opt$mode == "train") {
    train_model(data, model_name = opt$model_name, target_column = opt$target_column)
  } else if (opt$mode == "validate") {
    compute_monitoring_rmse(
      model_name = opt$model_name,
      alias = opt$model_alias,
      new_data = data,
      target_column = opt$target_column
    )
  } else {
    stop("Invalid mode provided. Use 'train' or 'validate'.")
  }
}

# Run the main function
main()
