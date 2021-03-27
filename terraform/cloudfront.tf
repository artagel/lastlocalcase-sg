// Cloudfront Distro with lambda@Edge integration
resource "aws_cloudfront_distribution" "pub_s3_distribution" {
  depends_on = [aws_s3_bucket.pub_s3_bucket]

  origin {
    domain_name = "${var.pub_domain_name}.s3.amazonaws.com"
    origin_id   = "s3-cloudfront"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.pub_origin_access_identity.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  aliases = [
    var.pub_domain_name,
  ]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]

    cached_methods = [
      "GET",
      "HEAD",
    ]

    lambda_function_association {
      event_type   = "origin-request"
      lambda_arn   = aws_lambda_function.pub_folder_index_redirect.qualified_arn
      include_body = false
    }

    target_origin_id = "s3-cloudfront"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.pub_acm_cert.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1"
  }
  custom_error_response {
    error_code            = 403
    response_code         = 200
    error_caching_min_ttl = 0
    response_page_path    = "/"
  }
}

resource "aws_cloudfront_origin_access_identity" "pub_origin_access_identity" {
  comment = "access-identity-${var.pub_domain_name}.s3.amazonaws.com"
}
