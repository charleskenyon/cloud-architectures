resource "aws_s3_bucket" "s3_codepipeline_bucket" {
  bucket        = "${var.arch}-pipeline-artifacts"
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "s3_codepipeline_bucket" {
  bucket = aws_s3_bucket.s3_codepipeline_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_versioning" "s3_codepipeline_bucket" {
  bucket = aws_s3_bucket.s3_codepipeline_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "artifacts" {
  bucket = aws_s3_bucket.s3_codepipeline_bucket.id

  rule {
    id     = "expire-old-artifacts"
    status = "Enabled"

    expiration {
      days = 7
    }

    filter {}
  }

  rule {
    id     = "abort-incomplete-multipart-upload"
    status = "Enabled"
    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }

    filter {}
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.s3_codepipeline_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.kms_key.id
      sse_algorithm     = "aws:kms"
    }
  }
}