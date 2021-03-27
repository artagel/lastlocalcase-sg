terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = var.aws_region.region
}

provider "aws" {
  region = var.aws_region.region
  alias  = "aws_cloudfront"
}