locals {
  apex_domain = var.domain_name
  www_domain  = "www.${var.domain_name}"
  all_domains = [local.apex_domain, local.www_domain]

  content_bucket_name = "${replace(var.domain_name, ".", "-")}-content"
}
