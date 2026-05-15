# GitHub OIDC provider — looked up, not managed.
# This account already has the provider configured (from prior CI setups in
# other repos). We use a data source so a `terraform destroy` of this module
# never deletes a provider that other workflows depend on. If you ever start
# from a fresh AWS account, create it once via the console or a dedicated
# bootstrap module before running this.
data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

data "aws_iam_policy_document" "deploy_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    # Restrict to pushes on main of the specific repo. No tags, no PRs, no
    # other branches. Tighten further (e.g. environment-scoped) later if
    # you add staging vs prod environments.
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:${var.github_repo}:ref:refs/heads/${var.github_branch}",
      ]
    }
  }
}

resource "aws_iam_role" "deploy" {
  name               = "github-actions-deploy-${replace(var.domain_name, ".", "-")}"
  assume_role_policy = data.aws_iam_policy_document.deploy_assume.json
  description        = "Assumed by GitHub Actions in ${var.github_repo} to deploy the site."
}

data "aws_iam_policy_document" "deploy_permissions" {
  # S3: list + read + write objects in the content bucket only.
  statement {
    sid    = "ContentBucketRW"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
    ]
    resources = [aws_s3_bucket.content.arn]
  }

  statement {
    sid    = "ContentObjectsRW"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    resources = ["${aws_s3_bucket.content.arn}/*"]
  }

  # CloudFront: invalidate cache on this distribution only.
  statement {
    sid       = "InvalidateDistribution"
    effect    = "Allow"
    actions   = ["cloudfront:CreateInvalidation"]
    resources = [aws_cloudfront_distribution.site.arn]
  }
}

resource "aws_iam_role_policy" "deploy" {
  name   = "deploy-permissions"
  role   = aws_iam_role.deploy.id
  policy = data.aws_iam_policy_document.deploy_permissions.json
}
