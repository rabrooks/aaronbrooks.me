# aaronbrooks.me

Personal site at [aaronbrooks.me](https://aaronbrooks.me) — notes on AI
systems, training infrastructure, LLM platforms, and CUDA-level
optimization.

## Layout

```
.
├── site/         # Astro + MDX project
├── infra/        # Terraform: S3 + CloudFront + ACM + Route53 + GitHub OIDC
│   └── bootstrap/  # One-time TF state bucket + lock table
└── .github/
    └── workflows/
        └── deploy.yml  # OIDC → S3 sync → CloudFront invalidation
```

## Local development

Requires Node 24 (LTS Krypton). With nvm installed:

```bash
nvm use         # reads .nvmrc → installs/uses Node 24
cd site
npm install
npm run dev     # http://localhost:4321
npm run build   # static output to site/dist/
```

## Deploys

Pushes to `main` that touch `site/**` trigger
`.github/workflows/deploy.yml`, which:

1. Builds the Astro site (`npm ci && npm run build`).
2. Assumes the AWS deploy role via GitHub OIDC.
3. Syncs `dist/` to S3 (two-pass: long cache for hashed assets,
   no-cache for HTML/XML).
4. Invalidates CloudFront.

The workflow needs three repo variables (Settings → Secrets and variables
→ Actions → Variables):

| Name | Source |
|---|---|
| `AWS_DEPLOY_ROLE_ARN` | `terraform output deploy_role_arn` |
| `S3_BUCKET` | `terraform output content_bucket` |
| `CLOUDFRONT_DISTRIBUTION_ID` | `terraform output cloudfront_distribution_id` |

## Infrastructure

See [`infra/README.md`](infra/README.md) for the full Terraform setup.
Account: `329604878778` (personal). Profile: `abrooks`. All resources are
in `us-east-1` (required for ACM certs used by CloudFront).
