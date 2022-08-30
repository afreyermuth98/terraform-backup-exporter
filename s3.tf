resource "aws_s3_bucket" "backup_bucket" {
  bucket_prefix = "my-backup-exporter-"
  tags = {
    Name = "backup-exporter-bucket"
  }
}

# Private ACL
resource "aws_s3_bucket_acl" "backup_bucket_acl" {
  bucket = aws_s3_bucket.backup_bucket.id
  acl    = "private"
}

# Encrypt bucket with KMS key
resource "aws_s3_bucket_server_side_encryption_configuration" "backup_bucket_encryption" {
  bucket = aws_s3_bucket.backup_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.backup_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

# Enable or not versioning
resource "aws_s3_bucket_versioning" "backup_bucket_versioning" {
  bucket = aws_s3_bucket.backup_bucket.id
  versioning_configuration {
    status = var.s3_versioning_status ? "Enabled" : "Disabled"
  }
}

# Block public access
resource "aws_s3_bucket_public_access_block" "default" {
  depends_on = [
    aws_s3_bucket.backup_bucket
  ]
  bucket = aws_s3_bucket.backup_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


