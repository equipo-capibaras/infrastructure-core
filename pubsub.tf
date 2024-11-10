resource "google_service_account" "pubsub" {
  account_id   = "pubsub"
  display_name = "Service Account PubSub"

  depends_on = [ google_project_service.iam ]
}
