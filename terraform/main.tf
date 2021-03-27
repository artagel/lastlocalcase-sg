terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  access_key = "AKIASLFW6NHW5OLKC4XU"
  secret_key = "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"
}

provider "aws" {
  region = "us-east-1"
  alias  = "aws_cloudfront"
  access_key = "AKIASLFW6NHW5OLKC4XU"
  secret_key = "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"
}