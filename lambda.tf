data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/index.js"
  output_path = "${path.module}/lambda_script.zip"
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda_rds_populator_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_vpc_access" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_lambda_function" "popula_banco" {
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  function_name    = "popula-banco-rds"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  runtime          = "nodejs18.x"
  timeout          = 30 

  vpc_config {
    subnet_ids         = [aws_subnet.privada_a.id, aws_subnet.privada_b.id]
    security_group_ids = [aws_security_group.sg_lambda.id]
  }

  environment {
    variables = {
      DB_HOST     = aws_db_instance.banco-cosmos.address
      DB_USER     = var.db_username
      DB_PASSWORD = var.db_password
      DB_NAME     = "bancocosmo"
    }
  }

  depends_on = [
    aws_db_instance.banco-cosmos,
    aws_iam_role_policy_attachment.lambda_vpc_access
  ]
}