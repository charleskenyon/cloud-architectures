resource "aws_lambda_function" "example_lambda" {
  function_name = var.function_name
  role          = aws_iam_role.example_lambda_role.arn
  package_type  = "Image"
  image_uri     = "${var.function_image}:latest"
  runtime       = "nodejs22.x"

  image_config {
    command = [var.handler]
  }

  memory_size = var.memory_size
  timeout     = var.timeout

  architectures = ["x86_64"]
}

data "aws_iam_policy_document" "example_lambda_assume_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "example_lambda_role" {
  name               = "${var.function_name}-role"
  assume_role_policy = data.aws_iam_policy_document.example_lambda_assume_policy.json
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.example_lambda_role.name
}