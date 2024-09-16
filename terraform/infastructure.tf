# Configure the AWS provider
provider "aws" {
  profile = "personal"
  region  = "us-east-1"
}

# Define the ECR repository
resource "aws_ecr_repository" "lambda_repo" {
  name = "hello-world-repo"
}

# Create a placeholder image in the ECR repository
resource "aws_ecr_lifecycle_policy" "lambda_repo_policy" {
  repository = aws_ecr_repository.lambda_repo.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Expire images older than 14 days"
        selection    = {
          tagStatus = "untagged"
          countType = "sinceImagePushed"
          countUnit = "days"
          countNumber = 90
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# Define the Lambda function
resource "aws_lambda_function" "hello_world" {
  function_name = "hello-world"
  role          = aws_iam_role.lambda_exec.arn
  package_type  = "Image"
  image_uri     = "396577395766.dkr.ecr.us-east-1.amazonaws.com/lambda-placeholder:latest" # Placeholder image URI
  memory_size   = 128
  timeout       = 5
}

# Define the IAM role for the Lambda function
resource "aws_iam_role" "lambda_exec" {
  name = "lambda-exec-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

# Attach the necessary policies to the IAM role
resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Build a role to assume for Github Actions to rebuild and push the Docker image and deploy the Lambda function
resource "aws_iam_role" "github_actions" {
  name = "github-actions-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
        Action    = "sts:AssumeRole"
      }
    ]
  })
}
