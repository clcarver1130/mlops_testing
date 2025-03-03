#!/bin/bash

# Used only during the intial creation of the infrastructure to build the Docker image. Github Actions will handle the process moving forward

# Variables
AWS_REGION="us-east-1"
AWS_ACCOUNT_ID="396577395766"
REPOSITORY_NAME="lambda-placeholder"
IMAGE_TAG="latest"

# Authenticate Docker to the ECR registry
aws ecr --profile personal get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

# Tag the Docker image
docker tag ${REPOSITORY_NAME}:${IMAGE_TAG} ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPOSITORY_NAME}:${IMAGE_TAG}

# Push the Docker image to ECR
docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPOSITORY_NAME}:${IMAGE_TAG}