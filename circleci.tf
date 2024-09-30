resource "google_service_account" "circleci" {
  account_id   = "circleci"
  display_name = "Service Account CircleCI"

  depends_on = [ google_project_service.iam ]
}

resource "google_service_account_iam_member" "workload_identity_circleci" {
  service_account_id = google_service_account.circleci.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.circleci.name}/attribute.org_id/${local.circleci_org_id}"
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
