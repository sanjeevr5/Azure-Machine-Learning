

import argparse
import mlflow
from sklearn.pipeline import Pipeline
from xgboost import XGBClassifier
import skl2onnx
from skl2onnx.common.shape_calculator import calculate_linear_classifier_output_shapes
from skl2onnx.common.data_types import FloatTensorType, Int64TensorType, StringTensorType
from onnxmltools.convert.xgboost.operator_converters.XGBoost import convert_xgboost


parser = argparse.ArgumentParser()

parser.add_argument('--data', type=str)
parser.add_argument('--feat_transformer_path', type=str)
parser.add_argument('--model_path', type=str)
parser.add_argument('--model_pipeline', type=str)
args = parser.parse_args()


feat_transformer = mlflow.sklearn.load_model(args.feat_transformer_path)
print('Feature transformer loaded')
xgboost_classifier = mlflow.xgboost.load_model(args.model_path)
print('XGBCLassifier loaded')

input_types = [('age', FloatTensorType(shape=[None, 1])),
 ('sex', Int64TensorType(shape=[None, 1])),
 ('cp', Int64TensorType(shape=[None, 1])),
 ('trestbps', Int64TensorType(shape=[None, 1])),
 ('chol', Int64TensorType(shape=[None, 1])),
 ('fbs', Int64TensorType(shape=[None, 1])),
 ('restecg', Int64TensorType(shape=[None, 1])),
 ('thalach', Int64TensorType(shape=[None, 1])),
 ('exang', Int64TensorType(shape=[None, 1])),
 ('oldpeak', FloatTensorType(shape=[None, 1])),
 ('slope', Int64TensorType(shape=[None, 1])),
 ('ca', Int64TensorType(shape=[None, 1])),
 ('thal', StringTensorType(shape=[None, 1]))]


skl2onnx.update_registered_converter(XGBClassifier, 'XGBoostXGBClassifier',
    calculate_linear_classifier_output_shapes, convert_xgboost,
    options={'nocl': [True, False], 'zipmap': [True, False, 'columns']})

print('Registered converter')

pipeline = Pipeline(steps=[('transformer', feat_transformer),
                              ('xgbc', xgboost_classifier)
                    ])

print('Pipeline constructed')


model_onnx = skl2onnx.convert_sklearn(
    pipeline, 'pipeline_heart_classification',
    input_types,
    target_opset = {'': 12, 'ai.onnx.ml': 2})

print('Model ONNX successful')

mlflow.onnx.save_model(model_onnx, path = args.model_pipeline)
mlflow.onnx.log_model(model_onnx, registered_model_name = 'heart_disease_prediction_model', artifact_path = args.model_pipeline)
