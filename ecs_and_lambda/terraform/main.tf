provider "aws" {
  region = "us-east-1"
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda-to-ecs-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda-to-ecs-policy"
  role = aws_iam_role.lambda_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "ecs:RunTask",
          "iam:PassRole",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_lambda_function" "lambda_to_ecs" {
  function_name = "lambda-to-ecs-test"
  role          = aws_iam_role.lambda_role.arn
  package_type  = "Image"
  image_uri     = "396577395766.dkr.ecr.us-east-1.amazonaws.com/lambda-to-ecs-repo:latest"
  environment {
    variables = {
      LOG_GROUP_NAME = aws_cloudwatch_log_group.lambda_log_group.name
    }
  }
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "ecs-test-cluster"
}

resource "aws_ecs_task_definition" "ecs_task" {
  family = "ecs-task-family"
  container_definitions = jsonencode([
    {
      name      = "ecs-container",
      image     = "396577395766.dkr.ecr.us-east-1.amazonaws.com/ecs-task-repo:latest", # Placeholder image
      cpu       = 256,
      memory    = 512,
      essential = true,
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs_log_group.name
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
  requires_compatibilities = ["FARGATE"]
  network_mode       = "awsvpc"
  cpu                = "256"
  memory             = "512"
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_execution_role.arn
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs-task-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "ecs_task_execution_policy" {
  name = "ecs-task-execution-policy"
  role = aws_iam_role.ecs_task_execution_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:GetAuthorizationToken",
          "ecs:RunTask"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_ecr_repository" "lambda_repo" {
  name = "lambda-to-ecs-repo"
}

resource "aws_ecr_repository" "ecs_repo" {
  name = "ecs-task-repo"
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/lambda-to-ecs-test"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name              = "/ecs/ecs-task-family"
  retention_in_days = 14
}