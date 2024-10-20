resource "google_service_account" "backup" {
  account_id   = "backup"
  display_name = "Service Account Backup"

  depends_on = [ google_project_service.iam ]
}

resource "google_storage_bucket" "backup" {
  name                        = "${local.project_id}-backup"
  location                    = local.region
  force_destroy               = true
  uniform_bucket_level_access = true
}
