variable "gcp_region" {
  type        = string
  default     = "us-central1"
  description = "GCP region"
}

variable "gcp_project_id" {
  type        = string
  description = "GCP project ID"
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

variable "domain" {
  type        = string
  description = "Domain name"
}
