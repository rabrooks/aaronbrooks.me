terraform {
  required_version = ">= 1.9"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.40, < 7.0"
    }
  }
}

# Default provider — us-east-1 (required for ACM certs used by CloudFront).
# All resources for this project live here.
provider "aws" {
  region                   = "us-east-1"
  profile                  = var.aws_profile
  shared_credentials_files = ["~/.aws/credentials"]
  shared_config_files      = ["~/.aws/config"]

  # Refuse to operate against any account other than the personal one.
  allowed_account_ids = [var.aws_account_id]

  default_tags {
    tags = {
      Project   = "aaronbrooks.me"
      ManagedBy = "terraform"
    }
  }
}
