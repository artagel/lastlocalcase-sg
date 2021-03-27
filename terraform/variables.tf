variable "aws_region" {
  default     = "us-east-1"
  prod_prefix = "prod"
  dev_prefix  = "dev"
  description = "AWS Region to host S3 site"
  type        = string
}

variable "pub_domain_name" {
  default = "lastlocalcase.sg"
  description = "FQDN of cloudfront alias for the website"
  type        = string
}

variable "hosted_zone" {
  default = "lastlocalcase.sg"
  description = "Root domain of website"
  type        = string
}
