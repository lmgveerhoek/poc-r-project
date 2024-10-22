import os
from flask import Flask, request, jsonify
from mlflow.pyfunc import load_model
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)

MODEL_NAME = os.getenv('MODEL_NAME')
MODEL_ALIAS = os.getenv('MODEL_ALIAS', 'champion')
MLFLOW_TRACKING_URI = os.getenv('MLFLOW_TRACKING_URI')

# Load the model at startup
model = load_model(f"models:/{MODEL_NAME}@{MODEL_ALIAS}")

@app.route('/predict', methods=['POST'])
def predict():
    try:
        data = request.json
        predictions = model.predict(data)
        return jsonify({'predictions': predictions.tolist()})
    except Exception as e:
        return jsonify({'error': str(e)}), 400

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)
