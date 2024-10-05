resource "google_service_account" "circleci" {
  account_id   = "circleci"
  display_name = "Service Account CircleCI"

  depends_on = [ google_project_service.iam ]
}

resource "google_service_account" "circlecitf" {
  account_id   = "circlecitf"
  display_name = "Service Account CircleCI Terraform"

  depends_on = [ google_project_service.iam ]
}

resource "google_service_account_iam_member" "workload_identity_circleci" {
  service_account_id = google_service_account.circleci.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.circleci.name}/attribute.context_id/${local.circleci_context_id}"
}

resource "google_service_account_iam_member" "workload_identity_circlecitf" {
  service_account_id = google_service_account.circlecitf.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.circleci.name}/attribute.context_id/${local.circlecitf_context_id}"
}

resource "google_iam_workload_identity_pool" "circleci" {
  workload_identity_pool_id = "circleci"

  depends_on = [ google_project_service.iam ]
}

resource "google_iam_workload_identity_pool_provider" "circleci" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.circleci.workload_identity_pool_id
  workload_identity_pool_provider_id = "capibaras"
  attribute_mapping                  = {
    "google.subject" = "assertion.sub"
    "attribute.org_id" = "assertion.aud"
    "attribute.project" = "assertion['oidc.circleci.com/project-id']"
    "attribute.context_id" = "assertion['oidc.circleci.com/context-ids'][0]"
  }
  oidc {
    issuer_uri = "https://oidc.circleci.com/org/${local.circleci_org_id}"
    allowed_audiences = [ local.circleci_org_id ]
  }
}

resource "google_storage_bucket_iam_member" "circleci_front_read" {
  bucket = google_storage_bucket.front.name
  role   = "roles/storage.legacyBucketReader"
  member = google_service_account.circleci.member
}

resource "google_storage_bucket_iam_member" "circleci_front_write" {
  bucket = google_storage_bucket.front.name
  role   = "roles/storage.objectUser"
  member = google_service_account.circleci.member
}

resource "google_project_iam_member" "circleci_cache" {
  project = local.project_id
  role    = google_project_iam_custom_role.cache_controller.id
  member  = google_service_account.circleci.member
}

resource "google_artifact_registry_repository_iam_member" "circleci_repo_access" {
  repository = google_artifact_registry_repository.default.name
  location = google_artifact_registry_repository.default.location
  role   = "roles/artifactregistry.writer"
  member = google_service_account.circleci.member
}

resource "google_project_iam_custom_role" "cloud_run_deployer" {
  role_id     = "cloudRunDeployer"
  title       = "Cloud Run Deployer"
  permissions = [
    "run.services.get",
    "run.services.update",
]

  depends_on = [ google_project_service.iam ]
}

resource "google_project_iam_member" "cloud_run_deployer" {
  project = local.project_id
  role    = google_project_iam_custom_role.cloud_run_deployer.id
  member  = google_service_account.circleci.member
}

resource "google_project_iam_member" "project_read" {
  project = local.project_id
  role    = "roles/viewer"
  member  = google_service_account.circleci.member
}

resource "google_project_iam_member" "secret_access" {
  project = local.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = google_service_account.circleci.member
}

data "google_storage_bucket" "tfstate" {
  name = local.tfstate_bucket
}

resource "google_storage_bucket_iam_member" "tfstate_read" {
  bucket = data.google_storage_bucket.tfstate.name
  role   = "roles/storage.objectViewer"
  member = google_service_account.circleci.member
}

resource "google_project_iam_member" "tf_project_editor" {
  project = local.project_id
  role    = "roles/editor"
  member  = google_service_account.circlecitf.member
}

resource "google_project_iam_member" "tf_storage_admin" {
  project = local.project_id
  role   = "roles/storage.admin"
  member = google_service_account.circlecitf.member
}
