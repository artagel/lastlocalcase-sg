// Public Repository
data "aws_route53_zone" "pub_domain_name" {
  name         = var.hosted_zone
  private_zone = false
}

resource "aws_route53_record" "pub_route53_record" {
  depends_on = [
    aws_cloudfront_distribution.pub_s3_distribution,
  ]

  zone_id = data.aws_route53_zone.pub_domain_name.zone_id
  name    = var.pub_domain_name
  type    = "A"

  alias {
    name    = aws_cloudfront_distribution.pub_s3_distribution.domain_name
    zone_id = aws_cloudfront_distribution.pub_s3_distribution.hosted_zone_id

    //HardCoded value for CloudFront
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "pub_cert_validation" {
  provider = aws.aws_cloudfront
  allow_overwrite = true
  name            = tolist(aws_acm_certificate.pub_acm_cert.domain_validation_options)[0].resource_record_name
  records         = [ tolist(aws_acm_certificate.pub_acm_cert.domain_validation_options)[0].resource_record_value ]
  type            = tolist(aws_acm_certificate.pub_acm_cert.domain_validation_options)[0].resource_record_type
  zone_id  = data.aws_route53_zone.pub_domain_name.id
  ttl      = 60
}
