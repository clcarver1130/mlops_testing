FROM amazonlinux

# Install Python
RUN yum install -y python3

COPY ecs_and_lambda/ecs/ecs.py /app/ecs.py

CMD ["python3", "/app/ecs.py"]