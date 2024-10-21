import mlflow
import os
from dotenv import load_dotenv

load_dotenv()

mlflow.set_tracking_uri(os.getenv('MLFLOW_TRACKING_URI'))
model_name = os.getenv('MODEL_NAME')
model_alias = os.getenv('MODEL_ALIAS', 'champion')

latest_version = mlflow.pyfunc.load_model(f"models:/{model_name}@{model_alias}")
# Compare with currently deployed version and trigger update if different
