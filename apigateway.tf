resource "google_project_service" "servicecontrol" {
  service = "servicecontrol.googleapis.com"

  disable_on_destroy = false
}

resource "google_project_service" "servicemanagement" {
  service = "servicemanagement.googleapis.com"

  disable_on_destroy = false
}

resource "google_project_service" "apigateway" {
  service = "apigateway.googleapis.com"

  disable_on_destroy = false
}

resource "google_service_account" "apigateway" {
  account_id   = "apigateway"
  display_name = "Service Account API Gateway"

  depends_on = [ google_project_service.iam ]
}

resource "google_api_gateway_api" "default" {
  provider = google-beta
  api_id = local.api_id

  depends_on = [
    google_project_service.apigateway,
    google_project_service.servicecontrol,
    google_project_service.servicemanagement
  ]
}

locals {
  openapi_spec = templatefile("ABCall.swagger.yaml", {
    jwt_issuer = "https://${local.domain}"
    jwt_jwks = "https://${local.domain}/.well-known/jwks.json"
    client_url = "https://client-${data.google_project.default.number}.${local.region}.run.app"
    user_url = "https://user-${data.google_project.default.number}.${local.region}.run.app"
    incidentmodify_url = "https://incidentmodify-${data.google_project.default.number}.${local.region}.run.app"
    incidentquery_url = "https://incidentquery-${data.google_project.default.number}.${local.region}.run.app"
    registroapp_url = "https://registroapp-${data.google_project.default.number}.${local.region}.run.app"
    registromail_url = "https://registromail-${data.google_project.default.number}.${local.region}.run.app"
    invoice_url = "https://invoice-${data.google_project.default.number}.${local.region}.run.app"
    notification_url = "https://notification-${data.google_project.default.number}.${local.region}.run.app"
  })
}

resource "google_api_gateway_api_config" "default" {
  provider = google-beta
  api = google_api_gateway_api.default.api_id

  openapi_documents {
    document {
      path = "spec.yaml"
      contents = base64encode(local.openapi_spec)
    }
  }

  gateway_config {
    backend_config {
      google_service_account = google_service_account.apigateway.email
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_api_gateway_gateway" "default" {
  provider = google-beta
  api_config = google_api_gateway_api_config.default.id
  gateway_id = "${local.api_id}-gw"
  region = local.region
}
