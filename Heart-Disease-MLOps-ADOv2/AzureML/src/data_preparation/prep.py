"""
Data preparation step for the heart disease prediction a binary classification problem.
"""
import os
import sys
from pathlib import Path
import argparse
import pandas as pd
import numpy as np

from sklearn.impute import SimpleImputer
from sklearn.preprocessing import (OrdinalEncoder, OneHotEncoder, StandardScaler)
from sklearn.compose import ColumnTransformer
from sklearn.model_selection import train_test_split
from sklearn.pipeline import Pipeline

import mlflow
from mlflow.models.signature import infer_signature

continuous_features = ['age', 'chol', 'oldpeak', 'thalach', 'trestbps']
discrete_features = ['ca', 'cp', 'exang', 'fbs', 'restecg', 'sex', 'slope', 'thal']
target_column = 'target'

def parseArgs():
    """
        Parse arguments for the data preparation
    """
    parser = argparse.ArgumentParser()
    parser.add_argument('--raw_data', type = str)
    parser.add_argument('--categorical_encoding', type = str, required = False)
    parser.add_argument('--test_size', type = float, default = 0.3)
    parser.add_argument('--prepared_data', type = str)
    parser.add_argument('--transformations_output', type = str)
    parser.add_argument('--log_model', type = float, default = 1.0)
    return parser.parse_args()

def preprocessing_pipeline(categorical_encoding, cf, df): 
    """
        Encoding the categorical and continuous features for modeling.
        cf -> Continuous feat df -> discrete feat
    """
    try:
        if categorical_encoding == 'ordinal':
            cat_enc = OrdinalEncoder(handle_unknown='use_encoded_value', unknown_value=np.nan)
        elif categorical_encoding == 'onehot':
            cat_enc = OneHotEncoder(handle_unknown="ignore")
        else:
            raise NotImplementedError('Possible values are ordinal or onehot')

        conti_feat_pipeline = Pipeline([
            ('imputer', SimpleImputer(strategy = 'median')),
            ('scaler', StandardScaler())
        ])

        disc_feat_pipeline = Pipeline([
            #('imputer', SimpleImputer(strategy = 'most_frequent')), -- does not work with ONNX
            ('encoder', cat_enc)

        ])

        transformations = ColumnTransformer([
            ('conti_feat_pipeline', conti_feat_pipeline, cf),
            ('disc_feat_pipeline', disc_feat_pipeline, df)
        ])
        return transformations
    
    except Exception as e:

        exc_type, exc_obj, exc_tb = sys.exc_info()
        fname = os.path.split(exc_tb.tb_frame.f_code.co_filename)[1]
        print(exc_type, fname, exc_tb.tb_lineno, e)

def preprocess_data(dataframe, label, cf, df, cat_enc = 'ordinal', transformations = None):
    
    try:
    
        if label in dataframe.columns:
            X = dataframe.iloc[:,:-1]
            restore_target = True
        else:
            X = dataframe
            restore_target = False

        if transformations:
            X_transformed = transformations.transform(X)
        else:
            transformations = preprocessing_pipeline(cat_enc, cf, df)
            X_transformed = transformations.fit_transform(X)
        transformed_discrete_features = (
            transformations.transformers_[1][1]
            .named_steps["encoder"]
            .get_feature_names_out(discrete_features)
        )
        all_features = continuous_features + list(transformed_discrete_features)

        if restore_target:
            target_values = dataframe[label].to_numpy().reshape(len(dataframe), 1)
            X_transformed = np.hstack((X_transformed, target_values))
            all_features.append(label)

        return pd.DataFrame(X_transformed, columns = all_features), transformations
    
    except Exception as e:
        exc_type, exc_obj, exc_tb = sys.exc_info()
        fname = os.path.split(exc_tb.tb_frame.f_code.co_filename)[1]
        print(exc_type, fname, exc_tb.tb_lineno, e)

def main(args):
    try:
        raw = pd.read_csv(args.raw_data)
        preprocessed, transformations = preprocess_data(
            raw,
            target_column,
            continuous_features,
            discrete_features,
            args.categorical_encoding,
            None
        )
        train, test = train_test_split(preprocessed, test_size = args.test_size,
                                       random_state = 42, stratify = preprocessed.target)

        raw.to_csv(str(Path(args.prepared_data) / 'raw.csv'), index=False)
        train.to_csv(str(Path(args.prepared_data) / 'train.csv'), index=False)
        test.to_csv(str(Path(args.prepared_data) / 'test.csv'), index=False)


        signature = infer_signature(raw.iloc[:,:-1])

        mlflow.sklearn.save_model(
            sk_model = transformations,
            path = str(Path(args.transformations_output)),
            signature = signature
        )

        if args.log_model:

            mlflow.log_metric('Split ratio', args.test_size)
            mlflow.log_metric('Train shape', train.shape)
            mlflow.log_metric('Test shape', test.shape)

            mlflow.sklearn.log_model(
            sk_model = transformations,
            registered_model_name = 'heart_disease_feat_transformer',
            artifact_path = str(Path(args.transformations_output)),
            signature = signature
            )
        
    except Exception as e:
        exc_type, exc_obj, exc_tb = sys.exc_info()
        fname = os.path.split(exc_tb.tb_frame.f_code.co_filename)[1]
        print(exc_type, fname, exc_tb.tb_lineno, e)

if __name__ == '__main__':
    args = parseArgs()
    with mlflow.start_run() as run_experiment:
        main(args)