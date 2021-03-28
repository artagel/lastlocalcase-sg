data "archive_file" "pub_covid_scraper_zip" {
  type        = "zip"
  output_path = "${path.module}/covid_scraper.py.zip"
  source_file = "${path.module}/covid_scraper.py"
}

resource "aws_iam_role_policy" "pub_lambda_covid" {
  name_prefix = "pub-lambda-covid-policy-"
  role        = aws_iam_role.pub_lambda_covid.id

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

resource "aws_iam_role" "pub_lambda_covid" {
  name_prefix        = "pub-lambda-covid-policy-"
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

resource "aws_lambda_function" "pub_covid_scraper" {
  description      = "Managed by Terraform"
  filename         = "${path.module}/covid_scraper.py.zip"
  function_name    = "covid_scraper"
  handler          = "covid_scraper.handler"
  source_code_hash = data.archive_file.pub_covid_scraper_zip.output_base64sha256
  publish          = true
  timeout          = 30
  role             = aws_iam_role.pub_lambda_covid.arn
  runtime          = "python3.8"

}

resource "aws_lambda_permission" "allow_covid_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.pub_covid_scraper.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.pub_s3_bucket.arn
}

resource "aws_cloudwatch_event_rule" "every_one_hour" {
  name                = "every-one-hour"
  description         = "Fires every one hour"
  schedule_expression = "rate(1 hour)"
}

resource "aws_cloudwatch_event_target" "check_covid_every_one_hour" {
  rule      = "${aws_cloudwatch_event_rule.every_one_hour.name}"
  target_id = "lambda"
  arn       = "${aws_lambda_function.pub_covid_scraper.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_check_covid" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.pub_covid_scraper.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.every_one_hour.arn}"
}
