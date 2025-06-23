resource "aws_s3_bucket" "notifier" {
  bucket = var.bucket_name
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/notify_webhook.py"
  output_path = "${path.module}/lambda/notify_webhook.zip"
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "notifier" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "s3_notifier"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "notify_webhook.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  environment {
    variables = {
      WEBHOOK_URL = var.webhook_url
    }
  }
}

resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.notifier.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.notifier.arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.notifier.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.notifier.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_s3]
} 