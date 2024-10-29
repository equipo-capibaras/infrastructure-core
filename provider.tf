terraform {
  required_providers {
    google = {
      version = "~> 6.9.0"
    }

    google-beta = {
      version = "~> 6.8.0"
    }
  }
}

terraform {
  backend "gcs" {
    prefix = "core/state"
  }
}

provider "google" {
  project = local.project_id
  region  = local.region
}

provider "google-beta" {
  project = local.project_id
  region  = local.region
}
