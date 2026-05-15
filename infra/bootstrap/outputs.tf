output "state_bucket" {
  value       = aws_s3_bucket.tfstate.bucket
  description = "S3 bucket for Terraform state. Reference in the main module's backend.tf."
}

output "lock_table" {
  value       = aws_dynamodb_table.tfstate_locks.name
  description = "DynamoDB table for Terraform state locks."
}

output "region" {
  value = "us-east-1"
}
