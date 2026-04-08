provider "aws" {
  region = "ap-south-2"
}

resource "random_id" "rand" {
  byte_length = 4
}

# SNS Topic
resource "aws_sns_topic" "alerts" {
  name = "finops-alerts"
}

resource "aws_sns_topic_subscription" "email_sub" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.email
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "finops_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policies" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
    "arn:aws:iam::aws:policy/CloudWatchFullAccess",
    "arn:aws:iam::aws:policy/AmazonSNSFullAccess"
  ])

  role       = aws_iam_role.lambda_role.name
  policy_arn = each.value
}

# Lambda Function
resource "aws_lambda_function" "finops_lambda" {
  function_name = "detect_idle_ec2"

  filename         = "lambda.zip"
  source_code_hash = filebase64sha256("lambda.zip")

  runtime = "python3.10"
  handler = "lambda_function.lambda_handler"

  role = aws_iam_role.lambda_role.arn

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.alerts.arn
    }
  }
}

# EventBridge Schedule
resource "aws_cloudwatch_event_rule" "daily" {
  name                = "daily-finops-run"
  schedule_expression = "rate(1 day)"
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.daily.name
  target_id = "lambda"
  arn       = aws_lambda_function.finops_lambda.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.finops_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daily.arn
}