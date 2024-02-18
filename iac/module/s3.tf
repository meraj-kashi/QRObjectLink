# Create S3 bucket
resource "aws_s3_bucket" "qrobjectlink_s3" {
  bucket_prefix = "${local.name_prefix}-"
  force_destroy = var.s3_force_destroy
  tags          = local.tags
}

# Set S3s acl to private
resource "aws_s3_bucket_acl" "qrobjectlink_s3_acl" {
  bucket     = aws_s3_bucket.qrobjectlink_s3.id
  acl        = "private"
  depends_on = [aws_s3_bucket_ownership_controls.qrobjectlink_s3_bucket_acl_ownership]
}

# Resource to avoid error "AccessControlListNotSupported: The bucket does not allow ACLs"
resource "aws_s3_bucket_ownership_controls" "qrobjectlink_s3_bucket_acl_ownership" {
  bucket = aws_s3_bucket.qrobjectlink_s3.id
  rule {
    object_ownership = "ObjectWriter"
  }
}

# Create KMS key
resource "aws_kms_key" "qrobjectlink_kms" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}

# Set S3 server side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "qrobjectlink_s3_encrypt" {
  bucket = aws_s3_bucket.qrobjectlink_s3.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.qrobjectlink_kms.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

# Set S3 versioning
resource "aws_s3_bucket_versioning" "qrobjectlink_s3_versioning" {
  bucket = aws_s3_bucket.qrobjectlink_s3.id
  versioning_configuration {
    status = "Enabled"
  }
}


# Zip file (handler.zip)
data "archive_file" "qrobjectlink_dummy_zip" {
  type        = "zip"
  output_path = "dummy.zip"

  source {
    content  = "placeholder"
    filename = "dummy.txt"
  }
}


######################################################################
# Upload dummy API handler files to s3 bucket
######################################################################
# - Add dummy object when a new Lambda API is created
######################################################################

# S3 dummy object 
resource "aws_s3_object" "dummy_s3_object_presigned_url_api" {
  key    = "${local.name}-apis/presigned-url/handler.zip"
  bucket = aws_s3_bucket.qrobjectlink_s3.id
  acl    = "private"
  source = data.archive_file.qrobjectlink_dummy_zip.output_path

  depends_on = [
    aws_s3_bucket.qrobjectlink_s3,
    data.archive_file.qrobjectlink_dummy_zip
  ]
}

# S3 dummy object 
resource "aws_s3_object" "dummy_s3_object_qr_code_api" {
  key    = "${local.name}-apis/qr-code/handler.zip"
  bucket = aws_s3_bucket.qrobjectlink_s3.id
  acl    = "private"
  source = data.archive_file.qrobjectlink_dummy_zip.output_path

  depends_on = [
    aws_s3_bucket.qrobjectlink_s3,
    data.archive_file.qrobjectlink_dummy_zip
  ]
}
