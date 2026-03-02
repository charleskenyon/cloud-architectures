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