# Terraform state bootstrap

One-time setup. Creates the S3 bucket and DynamoDB table that the main
module's S3 backend uses for remote state and locking.

```bash
cd infra/bootstrap
terraform init
terraform plan
terraform apply
```

After this completes, the main module (one directory up) can run
`terraform init` against the S3 backend.

This module uses **local state** intentionally — it's the chicken-and-egg
exception. The local state file (`terraform.tfstate`) is committed to git
on purpose so the bootstrap is reproducible; it contains no secrets, only
resource IDs.
