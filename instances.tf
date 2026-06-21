resource "google_compute_instance" "prod" {
  name                = "prod-vm"
  machine_type        = "e2-micro"
  zone                = var.prod_zone
  deletion_protection = false

  depends_on = [
    google_compute_router_nat.nat
  ]

  tags = ["web"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet.id
  }

  metadata_startup_script = file("${path.module}/startup/prod.sh")
}

resource "google_compute_instance" "maintenance" {
  name                = "maintenance-vm"
  machine_type        = "e2-micro"
  zone                = var.maintenance_zone
  deletion_protection = false

  depends_on = [
    google_compute_router_nat.nat
  ]

  tags = ["web"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet.id
  }

  metadata_startup_script = file("${path.module}/startup/maintenance.sh")
}

resource "google_compute_instance_group" "prod_group" {
  name = "prod-group"
  zone = var.prod_zone

  instances = [
    google_compute_instance.prod.id
  ]

  named_port {
    name = "http"
    port = 80
  }
}

resource "google_compute_instance_group" "maintenance_group" {
  name = "maintenance-group"
  zone = var.maintenance_zone

  instances = [
    google_compute_instance.maintenance.id
  ]

  named_port {
    name = "http"
    port = 80
  }
}

resource "google_compute_health_check" "http" {
  name = "http-health-check"

  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 3

  http_health_check {
    port = 80
  }
}