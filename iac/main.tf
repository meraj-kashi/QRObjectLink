provider "aws" {
  region = var.aws_region
}

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

module "cv_digitalisering" {
  source          = "./module"
  region          = var.aws_region
  environment     = var.environment
  tags            = var.tags
  account_id      = var.account_id
  name            = var.name
  s3_bucket_store = var.s3_bucket_store
}
