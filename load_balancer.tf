resource "google_compute_backend_service" "web" {
  name                  = "web-backend"
  protocol              = "HTTP"
  port_name             = "http"
  timeout_sec           = 10
  session_affinity      = "NONE"
  load_balancing_scheme = "EXTERNAL"

  health_checks = [
    google_compute_health_check.http.id
  ]

  backend {
    group           = google_compute_instance_group.prod_group.id
    balancing_mode  = "UTILIZATION"
    capacity_scaler = var.prod_weight / 100
  }

  backend {
    group           = google_compute_instance_group.maintenance_group.id
    balancing_mode  = "UTILIZATION"
    capacity_scaler = var.maintenance_weight / 100
  }
}

resource "google_compute_url_map" "web" {
  name            = "web-map"
  default_service = google_compute_backend_service.web.id
}

resource "google_compute_target_http_proxy" "web" {
  name    = "web-proxy"
  url_map = google_compute_url_map.web.id
}

resource "google_compute_global_address" "web" {
  name = "web-ip"
}

resource "google_compute_global_forwarding_rule" "web" {
  name                  = "web-forwarding-rule"
  ip_address            = google_compute_global_address.web.address
  port_range            = "80"
  target                = google_compute_target_http_proxy.web.id
  load_balancing_scheme = "EXTERNAL"
}