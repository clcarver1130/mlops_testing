#!/bin/bash

# Used only during the intial creation of the infrastructure to build the Docker image. Github Actions will handle the process moving forward

# Variables
REPOSITORY_NAME="lambda-placeholder"
IMAGE_TAG="latest"

# Build the Docker image
docker build -t ${REPOSITORY_NAME}:${IMAGE_TAG} .