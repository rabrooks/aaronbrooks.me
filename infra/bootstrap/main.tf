terraform {
  required_version = ">= 1.9"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.40, < 7.0"
    }
  }
  # Local state — the whole point of this module is to bootstrap the remote
  # state backend used by the main module. Run once.
}

provider "aws" {
  region                   = "us-east-1"
  profile                  = "abrooks"
  shared_credentials_files = ["~/.aws/credentials"]
  shared_config_files      = ["~/.aws/config"]

  # Defense in depth: refuse to run against any account other than the
  # personal one. If this profile ever points elsewhere, plan/apply will fail.
  allowed_account_ids = ["329604878778"]
}

variable "state_bucket_name" {
  description = "Globally unique S3 bucket name for Terraform state"
  type        = string
  default     = "aaronbrooks-tfstate-329604878778"
}

variable "lock_table_name" {
  description = "DynamoDB table name for Terraform state locking"
  type        = string
  default     = "aaronbrooks-tfstate-locks"
}

resource "aws_s3_bucket" "tfstate" {
  bucket = var.state_bucket_name

  tags = {
    Project = "aaronbrooks.me"
    Purpose = "terraform-state"
  }
}

resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "tfstate" {
  bucket                  = aws_s3_bucket.tfstate.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "tfstate_locks" {
  name         = var.lock_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Project = "aaronbrooks.me"
    Purpose = "terraform-state-locks"
  }
}
