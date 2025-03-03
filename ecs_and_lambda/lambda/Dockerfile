FROM public.ecr.aws/lambda/python:3.12

COPY ecs_and_lambda/lambda/lambda.py ${LAMBDA_TASK_ROOT}

CMD ["lambda.handler"]