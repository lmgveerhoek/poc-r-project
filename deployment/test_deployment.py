import requests
import json

def test_model_deployment():
    url = "http://localhost:8000/invocations"
    headers = {"Content-Type": "application/json"}
    data = {
        "columns": ["CRIM", "ZN", "INDUS", "CHAS", "NOX", "RM", "AGE", "DIS", "RAD", "TAX", "PTRATIO", "B", "LSTAT"],
        "data": [[0.00632, 18.0, 2.31, 0, 0.538, 6.575, 65.2, 4.0900, 1, 296.0, 15.3, 396.90, 4.98]]
    }

    response = requests.post(url, headers=headers, data=json.dumps(data))
    
    if response.status_code == 200:
        print("Prediction successful!")
        print("Predicted value:", response.json())
    else:
        print("Error in prediction:")
        print(response.text)

if __name__ == "__main__":
    test_model_deployment()
