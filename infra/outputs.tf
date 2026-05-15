output "content_bucket" {
  description = "Name of the S3 bucket holding the built site. Used by GitHub Actions for `aws s3 sync`."
  value       = aws_s3_bucket.content.bucket
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID. Used by GitHub Actions for `cloudfront create-invalidation`."
  value       = aws_cloudfront_distribution.site.id
}

output "cloudfront_domain_name" {
  description = "Default *.cloudfront.net hostname. Useful for direct testing before DNS propagates."
  value       = aws_cloudfront_distribution.site.domain_name
}

output "deploy_role_arn" {
  description = "IAM role ARN that GitHub Actions assumes via OIDC. Set as a repo secret or wire directly."
  value       = aws_iam_role.deploy.arn
}

output "site_url" {
  description = "Final public URL."
  value       = "https://${var.domain_name}/"
}
