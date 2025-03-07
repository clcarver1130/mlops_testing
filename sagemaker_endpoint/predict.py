import boto3
import json

AWS_PROFILE = "personal"

def invoke_sagemaker_endpoint(endpoint_name, input_data):
    session = boto3.Session(profile_name=AWS_PROFILE)
    runtime = session.client('sagemaker-runtime')
    payload = json.dumps(input_data)
    response = runtime.invoke_endpoint(
        EndpointName=endpoint_name,
        ContentType='application/json',
        Body=payload
    )
    result = json.loads(response['Body'].read().decode())
    return result


def test_random_prediction(endpoint_name='simple-model-endpoint'):
    import numpy as np
    sample_input = [list(np.random.random(10))]
    predictions = invoke_sagemaker_endpoint(endpoint_name, sample_input)
    print(predictions)


if __name__ == "__main__":
    test_random_prediction()