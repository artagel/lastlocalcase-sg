resource "aws_acm_certificate" "pub_acm_cert" {
  domain_name   = var.pub_domain_name
  provider = aws.aws_cloudfront
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

