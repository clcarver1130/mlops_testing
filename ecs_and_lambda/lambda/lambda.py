import boto3


def handler(event, context):

    print('Starting Lambda function...')

    action = event.get('action')

    if action == 'ecs':
        print('Starting ECS task...')
        client = boto3.client('ecs')
        response = client.run_task(
            cluster='ecs-test-cluster',
            taskDefinition='ecs-task-family',
            launchType='FARGATE',
            networkConfiguration={
                'awsvpcConfiguration': {
                    'subnets': ['subnet-00a1991400af07d29'],
                    'assignPublicIp': 'ENABLED'
                }
            }
        )
    else:
        print('Hello Cam from AWS Lambda!')