data "archive_file" "pub_index_redirect_zip" {
  type        = "zip"
  output_path = "${path.module}/pub-last-index-redirect.js.zip"
  source_file = "${path.module}/lambda_edge/pub-last-index-redirect.js"
}

resource "aws_iam_role_policy" "pub_lambda_execution" {
  name_prefix = "pub-last-lambda-policy-"
  role        = aws_iam_role.pub_lambda_execution.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:CreateLogGroup"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF

}

resource "aws_iam_role" "pub_lambda_execution" {
  name_prefix        = "pub-last-lambda-policy-"
  description        = "Managed by Terraform"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "edgelambda.amazonaws.com",
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

resource "aws_lambda_function" "pub_folder_index_redirect" {
  description      = "Managed by Terraform"
  filename         = "${path.module}/pub-last-index-redirect.js.zip"
  function_name    = "pub-last-index-redirect"
  handler          = "pub-last-index-redirect.handler"
  source_code_hash = data.archive_file.pub_index_redirect_zip.output_base64sha256
  provider         = aws.aws_cloudfront
  publish          = true
  role             = aws_iam_role.pub_lambda_execution.arn
  runtime          = "nodejs10.x"

}

