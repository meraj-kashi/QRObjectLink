variable "name" {
  type        = string
  description = "A common name to apply to the names of all AWS resources."
  default     = ""
}

variable "environment" {
  description = "Runtime environment"
  type        = string
}

variable "tags" {
  type        = map(string)
  description = "A set of tags to apply to all respective AWS resources."
  default = {
    "managed_by" = "Terraform"
  }
}

variable "region" {
  type        = string
  description = "AWS account region"
}

variable "account_id" {
  type        = number
  description = "AWS Account ID"
}

variable "cw_log_retention_in_days" {
  type        = number
  description = "CloudWatch log retention in days"
  default     = 7
}

variable "s3_force_destroy" {
  type        = bool
  description = "Force destroying the S3 bucket (avoids errors if the bucket is not empty)"
  default     = true
}

variable "s3_bucket_store" {
  type        = string
  description = "S3 bucket storage to store uploaded objects"
}
