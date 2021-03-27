// Public Repository
output "pub_cloudfront_dist_id" {
  value = aws_cloudfront_distribution.pub_s3_distribution.id
}

output "pub_website_address" {
  value = var.pub_domain_name
}
