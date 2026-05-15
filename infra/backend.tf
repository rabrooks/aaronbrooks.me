terraform {
  backend "s3" {
    bucket       = "aaronbrooks-tfstate-329604878778"
    key          = "aaronbrooks.me/main.tfstate"
    region       = "us-east-1"
    profile      = "abrooks"
    encrypt      = true
    # S3-native locking (Terraform >= 1.10). Replaces the deprecated
    # `dynamodb_table` parameter. The DynamoDB table from bootstrap is
    # left in place for now in case of rollback; safe to remove later.
    use_lockfile = true
  }
}
