resource "google_project_service" "iam" {
  service = "iam.googleapis.com"

  disable_on_destroy = false
}

resource "google_service_account" "github" {
  account_id   = "github"
  display_name = "Service Account GitHub"

  depends_on = [ google_project_service.iam ]
}
