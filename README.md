# Energiebespaarders - Sample R project

This is a sample R project for the Energiebespaarders project. 

## Project structure

The project structure is as follows:

... 

## Get started

To get started with the project, follow the steps below:

1. Clone the project repository:

```bash
git clone
```

2. Copy the .env.example file to .env and fill in the required environment variables:

```bash
cp .env.example .env
```

Environment variables which need to be set are:
- MLFLOW_TRACKING_URI: the URI of the MLflow tracking server
- MLFLOW_TRACKING_USERNAME: the username for the MLflow tracking server
- MLFLOW_TRACKING_PASSWORD: the password for the MLflow tracking server
- GOOGLE_APPLICATION_CREDENTIALS: path to the Google service account key file
- GOOGLE_PROJECT_ID: the Google project ID


3. Install the required R packages, by running the following commands in the Rstudio console:

```bash
install.packages("renv")
renv::restore()
```

## Google BigQuery 

To be able to use Google BigQuery, you need to set up a service account and download the JSON key file. More information on this can be found [here](https://developers.google.com/workspace/guides/create-credentials).

The service account needs to have the following roles:
- BigQuery Data Viewer
- BigQuery Job User

After downloading the JSON key file, you need to set the path to the file in the .env file:

```bash
GOOGLE_APPLICATION_CREDENTIALS="path/to/your/json/key/file.json"
```

The default behaviour looks for a key file in the credentials folder, called `google-service-account.json`. If you want to use a different file, you need to specify the path in the .env file. 
If no entry in the .env file is found, a browser authentication flow will be started.

## MLflow

To be able to use MLFlow, create a virtual environment and install the required packages:

```bash
python3 -m venv .venv
source venv/bin/activate
pip install mlflow
```

If you choose to use a different location for the virtual environment, you need to specify the path in the .env file:

```bash
MLFLOW_PYTHON_BIN="path/to/your/virtual/environment/bin/python"
```

### Evaluating performance of a model

To evaluate the performance of a model, you can use the `compute_monitoring_rmse` function. This function takes the following arguments:

The best version of the model should have an alias of `champion` in the MLflow tracking server. The function will retrieve the best model from the tracking server and evaluate the performance of the model on the test set. 


