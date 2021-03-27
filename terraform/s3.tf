// Terraform State File
resource "aws_kms_key" "credentialbucketkey" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}

resource "aws_s3_bucket" "terraform_artifact_bucket" {
  bucket = "sg-lastlocalcase-artifact-bucket"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.credentialbucketkey.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
  versioning {
    enabled = true
  }
}

// Public Repository
data "aws_iam_policy_document" "pub_s3_bucket_policy" {
  statement {
    sid = "1"

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "arn:aws:s3:::${var.pub_domain_name}/*",
    ]

    principals {
      type = "AWS"

      identifiers = [
        aws_cloudfront_origin_access_identity.pub_origin_access_identity.iam_arn,
      ]
    }
  }
}

resource "aws_s3_bucket" "pub_s3_bucket" {
  bucket = var.pub_domain_name
  acl    = "private"

  versioning {
    enabled = true
  }

  policy = data.aws_iam_policy_document.pub_s3_bucket_policy.json
}

resource "aws_s3_bucket_public_access_block" "pub_s3_bucket_pub_policy" {
  bucket = var.pub_domain_name
  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_object" "pub_repo_html" {
  for_each      = fileset("../files/html/", "**/*")
  bucket        = var.pub_domain_name
  key           = replace(each.value, "../files/html/", "")
  source        = "../files/html/${each.value}"
  etag          = filemd5("../files/html/${each.value}")
  content_type = "text/html; charset=UTF-8"
}

