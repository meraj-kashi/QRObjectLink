variable "environment" {
  type        = string
  description = "AWS environment"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "account_id" {
  type        = string
  description = "AWS account id"
}

variable "tags" {
  description = "AWS tags"
  type        = map(string)
  default = {
    "managed_by" = "terraform"
  }
}

variable "name" {
  type        = string
  description = "A common name to apply to the names of all AWS resources."
  default     = ""
}

variable "s3_bucket_store" {
  type        = string
  description = "S3 bucket storage to store uploaded objects"
}
