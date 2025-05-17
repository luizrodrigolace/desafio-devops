resource "google_compute_global_address" "lb_ip" {
  name = "lb-ip-${var.environment}"
}

resource "google_compute_url_map" "url_map" {
  name            = "url-map-${var.environment}"
  default_service = google_compute_backend_service.default.id
}

resource "google_compute_backend_service" "default" {
  name                  = "backend-${var.environment}"
  protocol              = "HTTP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  timeout_sec           = 30

  backend {
    group = google_compute_region_network_endpoint_group.cloud_run_neg.id
  }

  security_policy = google_compute_security_policy.ip_allowlist.id
}

resource "google_compute_region_network_endpoint_group" "cloud_run_neg" {
  name                  = "neg-${var.environment}"
  region                = var.region
  network_endpoint_type = "SERVERLESS"
  cloud_run {
    service = var.cloud_run_service_name
  }
}

resource "google_compute_security_policy" "ip_allowlist" {
  name = "security-policy-${var.environment}"

  rule {
    action   = "allow"
    priority = "1000"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = var.allowed_ips
      }
    }
  }

  rule {
    action   = "deny(403)"
    priority = "2147483647"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
  }
}