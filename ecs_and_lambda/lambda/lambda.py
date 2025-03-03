import boto3


def handler(event, context):

    action = event.get('action')

    if action == 'ecs':
        client = boto3.client('ecs')
        response = client.run_task(
            cluster='ecs-test-cluster',
            taskDefinition='ecs-task-family',
            launchType='FARGATE',
            networkConfiguration={
                'awsvpcConfiguration': {
                    'subnets': ['subnet-12345678'],
                    'assignPublicIp': 'ENABLED'
                }
            }
        )
        return response
    else:
        print('Hello Cam from AWS Lambda!')