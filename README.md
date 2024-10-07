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

3. Install the required R packages, by running the following command in the Rstudio console (renv is required):

```bash
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