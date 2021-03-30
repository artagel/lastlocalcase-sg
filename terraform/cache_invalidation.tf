data "archive_file" "pub_invalidation_zip" {
  type        = "zip"
  output_path = "${path.module}/public_lastlocal_invalidation.py.zip"
  source_file = "${path.module}/lambda/public_lastlocal_invalidation.py"
}

resource "aws_iam_role_policy" "pub_lambda_invalidation_execution" {
  name_prefix = "public-invalidation-policy-"
  role        = aws_iam_role.pub_last_lambda_inv_exec.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:CreateLogGroup",
        "cloudfront:CreateInvalidation",
        "s3:GetBucketTagging"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF

}

resource "aws_iam_role" "pub_last_lambda_inv_exec" {
  name_prefix        = "public-last-inv-policy-"
  description        = "Managed by Terraform"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "lambda.amazonaws.com"
        ]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

resource "aws_lambda_function" "pub_s3_invalidation" {
  description      = "Managed by Terraform"
  filename         = "${path.module}/public_invalidation.py.zip"
  function_name    = "public_lastlocal_invalidation"
  handler          = "public_lastlocal_invalidation.handler"
  source_code_hash = data.archive_file.pub_invalidation_zip.output_base64sha256
  publish          = true
  timeout          = 30
  role             = aws_iam_role.pub_last_lambda_inv_exec.arn
  runtime          = "python3.8"

}


resource "aws_iam_role" "iam_for_lambda" {
  name = "pub_lastlocal_lambda_invalidation_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.pub_s3_invalidation.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.pub_s3_bucket.arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.pub_s3_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.pub_s3_invalidation.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}