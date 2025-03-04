import boto3
import logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def handler(event, context):

    logger.info('Starting Lambda function...')

    action = event.get('action')

    if action == 'ecs':
        logger.info('Starting ECS task...')
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
        logger.info('Hello Cam from AWS Lambda!')