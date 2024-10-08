variable "gcp_region" {
  type        = string
  default     = "us-central1"
  description = "GCP region"
}

variable "gcp_project_id" {
  type        = string
  description = "GCP project ID"
}

variable "tfstate_bucket" {
  type        = string
  description = "Bucket to store terraform state"
}

variable "registry_id" {
  type        = string
  default     = "repo"
  description = "Artifact registry ID"
}

variable "api_id" {
  type        = string
  default     = "abcall"
  description = "API Gateway API ID"
}

variable "github_org_id" {
  type        = string
  description = "GitHub Organization ID"
}

variable "circleci_org_id" {
  type        = string
  description = "CircleCI Organization ID"
}

variable "circleci_context_id" {
  type        = string
  description = "CircleCI Context ID that can use the circleci service account"
}

variable "circlecitf_context_id" {
  type        = string
  description = "CircleCI Context ID that can use the circlecitf service account"
}

variable "domain" {
  type        = string
  description = "Domain name"
}

variable "jwt_private_key" {
  type        = string
  description = "JWT private key"
}
