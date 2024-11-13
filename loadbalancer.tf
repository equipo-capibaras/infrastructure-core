resource "google_project_service" "certificatemanager" {
  service = "certificatemanager.googleapis.com"

  disable_on_destroy = false
}

resource "google_project_service" "compute" {
  service = "compute.googleapis.com"

  disable_on_destroy = false
}

resource "google_compute_region_network_endpoint_group" "apigw" {
  provider              = google-beta
  name                  = "neg-apigw"
  network_endpoint_type = "SERVERLESS"
  region                = local.region

  serverless_deployment {
    platform = "apigateway.googleapis.com"
    resource = google_api_gateway_gateway.default.gateway_id
  }
}

resource "google_compute_backend_service" "api" {
  name                  = "backend-api"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  protocol              = "HTTP"
  port_name             = "http"

  backend {
    group = google_compute_region_network_endpoint_group.apigw.id
  }
}

resource "google_storage_bucket" "front" {
  name                        = "${local.project_id}-front"
  location                    = local.region
  force_destroy               = true
  uniform_bucket_level_access = true
}

resource "google_storage_bucket_iam_member" "front_public" {
  bucket = google_storage_bucket.front.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

resource "google_compute_backend_bucket" "front" {
  name             = "backend-bucket-front"
  bucket_name      = google_storage_bucket.front.name
  enable_cdn       = true
  compression_mode = "AUTOMATIC"

  depends_on = [ google_project_service.compute ]
}

resource "google_project_iam_custom_role" "cache_controller" {
  role_id     = "lbCacheControl"
  title       = "Load Balancer Cache Controller"
  permissions = [ "compute.urlMaps.invalidateCache" ]

  depends_on = [ google_project_service.iam ]
}

resource "google_storage_bucket" "jwks" {
  name                        = "${local.project_id}-jwks"
  location                    = local.region
  force_destroy               = true
  uniform_bucket_level_access = true
}

resource "google_storage_bucket_iam_member" "jwks_public" {
  bucket = google_storage_bucket.jwks.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

resource "google_compute_backend_bucket" "jwks" {
  name             = "backend-bucket-jwks"
  bucket_name      = google_storage_bucket.jwks.name
  enable_cdn       = true
  compression_mode = "AUTOMATIC"

  depends_on = [ google_project_service.compute ]
}

resource "google_compute_url_map" "default" {
  name            = "lb-url-map"

  host_rule {
    hosts        = [ local.domain ]
    path_matcher = "allpaths"
  }

  default_url_redirect {
    host_redirect  = "hic.sunt.dracones.${local.domain}"
    https_redirect = true
    path_redirect  = ""
    strip_query    = true
  }

  path_matcher {
    name = "allpaths"

    route_rules {
      priority = 1
      service = google_compute_backend_bucket.jwks.id

      match_rules {
        full_path_match =  "/.well-known/jwks.json"
      }
    }

    route_rules {
      priority = 2
      service = google_compute_backend_service.api.self_link

      match_rules {
        full_path_match =  "/api"
      }

      match_rules {
        prefix_match =  "/api/"
      }
    }

    route_rules {
      priority = 3
      service = google_compute_backend_bucket.front.id

      match_rules {
        full_path_match =  "/es-CO/static"
      }

      match_rules {
        prefix_match =  "/es-CO/static/"
      }

      match_rules {
        full_path_match =  "/es-AR/static"
      }

      match_rules {
        prefix_match =  "/es-AR/static/"
      }

      match_rules {
        full_path_match =  "/pt-BR/static"
      }

      match_rules {
        prefix_match =  "/pt-BR/static/"
      }

      match_rules {
        full_path_match =  "/favicon.ico"
      }

      match_rules {
        full_path_match =  "/logo40.png"
      }

      match_rules {
        full_path_match =  "/es-CO/favicon.ico"
      }

      match_rules {
        full_path_match =  "/es-AR/favicon.ico"
      }

      match_rules {
        full_path_match =  "/pt-BR/favicon.ico"
      }
    }

    route_rules {
      priority = 4

      match_rules {
        full_path_match =  "/es-CO"
      }
      url_redirect {
        path_redirect = "/es-CO/"
      }
    }

    route_rules {
      priority = 5

      match_rules {
        full_path_match =  "/es-AR"
      }
      url_redirect {
        path_redirect = "/es-AR/"
      }
    }

    route_rules {
      priority = 6

      match_rules {
        full_path_match =  "/pt-BR"
      }
      url_redirect {
        path_redirect = "/pt-BR/"
      }
    }

    route_rules {
      priority = 7
      service = google_compute_backend_bucket.front.id

      match_rules {
        path_template_match =  "/es-CO/**"
      }

      route_action {
        url_rewrite {
          path_template_rewrite = "/es-CO/index.html"
        }
      }
    }

    route_rules {
      priority = 8
      service = google_compute_backend_bucket.front.id

      match_rules {
        path_template_match =  "/es-AR/**"
      }

      route_action {
        url_rewrite {
          path_template_rewrite = "/es-AR/index.html"
        }
      }
    }

    route_rules {
      priority = 9
      service = google_compute_backend_bucket.front.id

      match_rules {
        path_template_match =  "/pt-BR/**"
      }

      route_action {
        url_rewrite {
          path_template_rewrite = "/pt-BR/index.html"
        }
      }
    }

    route_rules {
      priority = 10
      service = google_compute_backend_bucket.front.id

      match_rules {
        path_template_match =  "/**"
      }

      route_action {
        url_rewrite {
          path_template_rewrite = "/index.html"
        }
      }
    }

    default_url_redirect {
      host_redirect  = "hic.sunt.dracones.${local.domain}"
      https_redirect = true
      path_redirect  = ""
      strip_query    = true
    }
  }
}

resource "google_compute_managed_ssl_certificate" "default" {
  name = "lb-cert"

  managed {
    domains = [ local.domain ]
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    google_project_service.certificatemanager,
    google_project_service.compute
  ]
}

resource "google_compute_ssl_policy" "default" {
  name            = "lb-ssl-policy"
  profile         = "RESTRICTED"
  min_tls_version = "TLS_1_2"

  depends_on = [ google_project_service.compute ]
}

resource "google_compute_target_https_proxy" "default" {
  name             = "lb-https-proxy"
  url_map          = google_compute_url_map.default.id
  ssl_certificates = [ google_compute_managed_ssl_certificate.default.id ]
  ssl_policy       = google_compute_ssl_policy.default.self_link
}

resource "google_compute_global_address" "default" {
  name = "lb-global-ip"

  depends_on = [ google_project_service.compute ]
}

resource "google_compute_global_forwarding_rule" "forwarding_rule" {
  name                  = "lb-frontend"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  target                = google_compute_target_https_proxy.default.self_link
  ip_address            = google_compute_global_address.default.address
  port_range            = "443"

  depends_on = [ google_compute_target_https_proxy.default ]
}
