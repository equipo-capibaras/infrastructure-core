# Enables the Secret Manager API for the project.
resource "google_project_service" "secretmanager" {
  service = "secretmanager.googleapis.com"

  # Prevents the API from being disabled when the resource is destroyed.
  disable_on_destroy = false
}

# Creates a Secret Manager secret to store the JWT private key.
resource "google_secret_manager_secret" "jwt_private_key" {
  secret_id = "jwt-private-key"
  replication {
    auto {}
  }

  depends_on = [ google_project_service.secretmanager ]
}

# Creates a version of the secret containing the JWT private key data.
resource "google_secret_manager_secret_version" "jwt_private_key" {
  secret = google_secret_manager_secret.jwt_private_key.id

  secret_data = local.jwt_private_key
}

# Creates a Secret Manager secret to store the Sendgrid API key.
resource "google_secret_manager_secret" "sendgrid_apikey" {
  secret_id = "sendgrid-apikey"
  replication {
    auto {}
  }

  depends_on = [ google_project_service.secretmanager ]
}

# Creates a version of the secret containing the Sendgrid API key data.
resource "google_secret_manager_secret_version" "sendgrid_apikey" {
  secret = google_secret_manager_secret.sendgrid_apikey.id

  secret_data = local.sendgrid_apikey
}
