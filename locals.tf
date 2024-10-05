locals {
  project_id = var.gcp_project_id
  region = var.gcp_region
  tfstate_bucket = var.tfstate_bucket
  registry_id = var.registry_id
  api_id = var.api_id
  github_org_id = var.github_org_id
  circleci_org_id = var.circleci_org_id
  circleci_context_id = var.circleci_context_id
  circlecitf_context_id = var.circlecitf_context_id
  domain = var.domain
}
