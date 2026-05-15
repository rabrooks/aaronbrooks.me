variable "aws_profile" {
  description = "AWS CLI profile to use. Must point to the personal account."
  type        = string
  default     = "abrooks"
}

variable "aws_account_id" {
  description = "Personal AWS account ID. Used as a guard via allowed_account_ids."
  type        = string
  default     = "329604878778"
}

variable "domain_name" {
  description = "Apex domain for the site (no www, no trailing dot)."
  type        = string
  default     = "aaronbrooks.me"
}

variable "hosted_zone_id" {
  description = "Existing Route53 hosted zone ID for domain_name."
  type        = string
  default     = "Z0817242202QJJJAO2J41"
}

variable "github_repo" {
  description = "GitHub repo allowed to assume the deploy role, in OWNER/REPO form."
  type        = string
  default     = "rabrooks/aaronbrooks.me"
}

variable "github_branch" {
  description = "Git branch from which deploys are allowed (main, prod, etc.)."
  type        = string
  default     = "main"
}

variable "price_class" {
  description = "CloudFront price class. PriceClass_100 = US/EU only (cheapest)."
  type        = string
  default     = "PriceClass_100"
}
