# Infrastructure — aaronbrooks.me

Terraform for the personal blog. Two modules:

- `bootstrap/` — one-time setup of S3 + DynamoDB for remote state. Local state.
- `.` (this directory) — main infrastructure: S3 content bucket, CloudFront,
  ACM certificate, Route53 records, GitHub OIDC role.

## Order of operations

```bash
# 1. Bootstrap remote state (run once per account).
cd bootstrap
terraform init
terraform apply

# 2. Main infra. Backend uses the bucket bootstrap just created.
cd ..
terraform init
terraform plan
terraform apply
```

## Prerequisites

- AWS CLI configured with the `abrooks` profile mapping to account `329604878778`.
- `aaronbrooks.me` already registered in Route53 (zone `Z0817242202QJJJAO2J41`).
- GitHub repo `rabrooks/aaronbrooks.me` exists (or override `var.github_repo`).

## Outputs to wire into CI

After `terraform apply`, take these outputs into the GitHub Actions workflow:

- `deploy_role_arn` → `AWS_DEPLOY_ROLE_ARN` repo variable
- `content_bucket` → `S3_BUCKET` repo variable
- `cloudfront_distribution_id` → `CLOUDFRONT_DISTRIBUTION_ID` repo variable

## Cost (approximate, low-traffic personal blog)

- Route53 hosted zone: $0.50/month (already paying for this)
- CloudFront: ~$0–1/month at low traffic (free tier covers 1TB egress)
- S3: ~$0.01/month for tens of MB of static assets
- ACM cert: free
- DynamoDB lock table: ~$0/month (PAY_PER_REQUEST, single-digit ops/month)

Total: ~$0.50–$3/month.

## Common operations

```bash
# Manually invalidate CloudFront cache (CI does this automatically).
aws cloudfront create-invalidation \
  --profile abrooks \
  --distribution-id $(terraform output -raw cloudfront_distribution_id) \
  --paths '/*'

# Sync local build directly (skipping CI).
aws s3 sync ../site/dist/ s3://$(terraform output -raw content_bucket)/ \
  --profile abrooks --delete
```

## If `aws_iam_openid_connect_provider.github` already exists

Some accounts have the GitHub OIDC provider from prior setups. If apply fails
with `EntityAlreadyExists`:

```bash
terraform import aws_iam_openid_connect_provider.github \
  arn:aws:iam::329604878778:oidc-provider/token.actions.githubusercontent.com
terraform apply
```
