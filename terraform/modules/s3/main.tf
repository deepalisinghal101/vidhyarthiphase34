resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "state" {
  bucket        = "${var.project_name}-infra-state-${random_id.bucket_suffix.hex}"
  force_destroy = false

  tags = {
    Name        = "${var.project_name}-state-bucket"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "public_block" {
  bucket = aws_s3_bucket.state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
