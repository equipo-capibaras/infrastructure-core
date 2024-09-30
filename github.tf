resource "google_service_account" "github" {
  account_id   = "github"
  display_name = "Service Account GitHub"

  depends_on = [ google_project_service.iam ]
}

resource "google_service_account_iam_member" "workload_identity_github" {
  service_account_id = google_service_account.github.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/attribute.repository_owner_id/${local.github_org_id}"
}

resource "google_iam_workload_identity_pool" "github" {
  workload_identity_pool_id = "github"

  depends_on = [ google_project_service.iam ]
}

resource "google_iam_workload_identity_pool_provider" "github" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = "capibaras"
  attribute_condition                = "assertion.repository_owner_id == '${local.github_org_id}'"
  attribute_mapping                  = {
    "google.subject" = "assertion.sub"
    "attribute.actor" = "assertion.actor"
    "attribute.actor_id" = "assertion.actor_id"
    "attribute.repository" = "assertion.repository"
    "attribute.repository_id" = "assertion.repository_id"
    "attribute.repository_owner" = "assertion.repository_owner"
    "attribute.repository_owner_id" = "assertion.repository_owner_id"
  }
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}
