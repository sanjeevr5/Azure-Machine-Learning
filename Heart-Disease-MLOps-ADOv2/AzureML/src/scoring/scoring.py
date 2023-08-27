#Writing inference schema to generate Swagger documentation automatically

from inference_schema.schema_decorators import input_schema, output_schema
from inference_schema.parameter_types.numpy_parameter_type import NumpyParameterType
from inference_schema.parameter_types.standard_py_parameter_type import (
    StandardPythonParameterType,
)
import os
import numpy as np
import logging
import onnxruntime as rt

model = None

def init():
    global model
    global ip_features
    model_dir = os.getenv('AZUREML_MODEL_DIR', '')
    model_path = os.path.join(model_dir, 'model_pipeline/model.onnx')
    model = rt.InferenceSession(model_path,
                           providers=["CPUExecutionProvider"])

@input_schema(
    param_name = 'data', param_type = NumpyParameterType(np.array([[63, 1, 1, 145, 233, 1, 2, 150, 0, 2.3, 3, 0, 'fixed']]))
)
@output_schema(output_type=StandardPythonParameterType({'Disease': ['Yes']}))
def run(data):
    
    logging.info(type(data))
    try:
        ip_features = [
            ('age', 'Float'),
            ('sex', 'Int'),
            ('cp', 'Int'),
            ('trestbps', 'Int'),
            ('chol', 'Int'),
            ('fbs', 'Int'),
            ('restecg', 'Int'),
            ('thalach', 'Int'),
            ('exang', 'Int'), 
            ('oldpeak', 'Float'),
            ('slope', 'Int'), 
            ('ca', 'Int'), 
            ('thal', '')
        ]
        inputs = {column[0] : [] for column in ip_features}
        targets = ['Yes', 'No']
        for row in data:
            for index, col in enumerate(ip_features):
                inputs[col[0]].append(row[index])
        for c in ip_features:
            if 'Float' == c[1]:
                inputs[c[0]] = np.array(inputs[c[0]]).astype(np.float32)
            elif 'Int' == c[1]:
                inputs[c[0]] = np.array(inputs[c[0]]).astype(np.int64)
            else:
                inputs[c[0]] = np.array(inputs[c[0]])
        for k in inputs:
            inputs[k] = inputs[k].reshape((inputs[k].shape[0], 1))
        pred_onx = model.run(None, inputs)
        predicted_categories = np.choose(pred_onx[0], targets).flatten()
        result = {
            "Disease": predicted_categories.tolist(),
        }
        return result
    except Exception as e:
        print(e)