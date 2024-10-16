import os
import boto3
from sagemaker.pytorch import PyTorchModel
from sagemaker import Session
import tarfile
from model import SimpleModel, save_model
from serve import MODEL_FILE_NAME
import torch

BUCKET_NAME = 'simple-model-artifacts'
AWS_PROFILE = 'personal'
ROLE_ARN = 'arn:aws:iam::396577395766:role/sagemaker-execution'


def push_model_to_s3(model_path, bucket_name=BUCKET_NAME):
    session = boto3.Session(profile_name=AWS_PROFILE)
    s3 = session.client('s3')
    archive_path = compress_model(model_path)
    key = os.path.basename(archive_path)
    s3.upload_file(
        Filename=archive_path,
        Bucket=bucket_name,
        Key=key
    )
    return f"s3://{bucket_name}/{key}"


def deploy_model(model_path, instance_type='ml.m5.large', endpoint_name='simple-model-endpoint', torch_version='2.3.0', py_version='py311'):
    boto_session = boto3.Session(profile_name=AWS_PROFILE)
    sagemaker_session = Session(boto_session=boto_session)
    model_uri = push_model_to_s3(model_path=model_path)

    if torch_version != torch.__version__.split("+")[0]:
        raise ValueError("Torch Version differs.")

    pytorch_model = PyTorchModel(
        model_data=model_uri,
        role=ROLE_ARN,
        framework_version=torch_version,
        py_version=py_version,
        entry_point='serve.py',
        source_dir='.',
        sagemaker_session=sagemaker_session
    )

    delete_endpoint_config(endpoint_name)

    pytorch_model.deploy(
        endpoint_name=endpoint_name,
        instance_type=instance_type,
        initial_instance_count=1
    )


def does_endpoint_config_exist(endpoint_config_name):
    sagemaker_client = boto3.client('sagemaker')
    try:
        sagemaker_client.describe_endpoint_config(EndpointConfigName=endpoint_config_name)
        return True
    except sagemaker_client.exceptions.ClientError:
        return False


def delete_endpoint_config(endpoint_config_name):
    sagemaker_client = boto3.client('sagemaker')
    if does_endpoint_config_exist(endpoint_config_name):
        sagemaker_client.delete_endpoint_config(EndpointConfigName=endpoint_config_name)


def compress_model(model_path):

    dir_name = os.path.dirname(model_path)
    file_name = os.path.basename(model_path)
    archive_file_name = f"{file_name}.tar.gz"
    with tarfile.open(os.path.join(dir_name, archive_file_name), 'w:gz') as tar:
        tar.add(model_path, arcname=file_name)

    return os.path.join(dir_name, archive_file_name)


def test_deploy_simple_model_directly():
    LOCAL_MODEL_DIR = './artifacts'

    os.makedirs(LOCAL_MODEL_DIR, exist_ok=True)
    LOCAL_MODEL_PATH = os.path.join(LOCAL_MODEL_DIR, MODEL_FILE_NAME)

    model = SimpleModel()
    save_model(model, LOCAL_MODEL_PATH)
    deploy_model(LOCAL_MODEL_PATH)


if __name__ == '__main__':
    test_deploy_simple_model_directly()