#!/bin/bash

# Variables
REPOSITORY_NAME="lambda-placeholder"
IMAGE_TAG="latest"

# Build the Docker image
docker build -t ${REPOSITORY_NAME}:${IMAGE_TAG} .