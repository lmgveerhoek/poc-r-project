# Model Deployment

This folder contains the necessary files to deploy the latest 'champion' model using Docker and MLflow's built-in serving capability.

## Setup

1. Ensure you have Docker installed on your system.
2. Copy the `.env.example` file to a new file named `.env`:   ```
   cp .env.example .env   ```
3. Update the `.env` file with the correct values for your MLflow setup.

## Environment Variables

The following environment variables need to be set in the `.env` file:

- `MODEL_NAME`: The name of your model in MLflow (default is 'Boston_Housing_MLR_Model')
- `MODEL_ALIAS`: The alias of the model version (default is 'champion')
- `MLFLOW_TRACKING_URI`: The URI of your MLflow tracking server

## Building and Running the Docker Container

1. Build the Docker image:   ```
   docker build -t mlflow-model-serve .   ```

2. Run the Docker container:   ```
   docker run -p 8000:8000 --env-fclile .env mlflow-model-serve   ```

The API will be available at `http://localhost:8000`.

## Running the Docker Container with Docker Compose

1. Build the Docker image:   
   ```
   docker build -t mlflow-model-serve .   
   ```

2. Run the Docker container with Docker Compose:  
   ```
   docker-compose up -d
   ```

3. To stop the Docker container, run:  
   ```
   docker-compose down
   ```

## Making Predictions

Send a POST request to `http://localhost:8000/invocations` with your input data as JSON.

Example using curl:
```
curl -X POST http://localhost:8000/invocations -H "Content-Type: application/json" -d '{"feature1": 1, "feature2": 2}'
```

For the Boston Housing dataset, the input should be a JSON object with the following features:

```
curl -X POST http://localhost:8000/invocations \
-H "Content-Type: application/json" \
-d '{"columns": ["CRIM", "ZN", "INDUS", "CHAS", "NOX", "RM", "AGE", "DIS", "RAD", "TAX", "PTRATIO", "B", "LSTAT"],
"data": [[0.00632, 18.0, 2.31, 0, 0.538, 6.575, 65.2, 4.0900, 1, 296.0, 15.3, 396.90, 4.98]]}'
```

This example uses the Boston Housing dataset features. Adjust the feature names and values according to your model's requirements.

## Testing the Deployment

To test the deployment of the Boston_Housing_MLR_Model@champion model:

1. Ensure your MLflow server is running and accessible.
2. Build and run the Docker container as described above.
3. Use the curl command provided in the "Making Predictions" section to send a test request.
4. Verify that you receive a prediction in the response.

## Automatic Deployment

To automatically deploy the latest 'champion' model, you can set up a CI/CD pipeline that:

1. Monitors your MLflow server for changes to the 'champion' alias.
2. Triggers a new Docker build and deployment when changes are detected.

You can use tools like Jenkins, GitLab CI, or GitHub Actions to implement this pipeline.
