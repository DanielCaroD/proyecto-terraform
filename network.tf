resource "google_compute_network" "vpc" {
  name                    = "taller-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = "taller-subnet"
  region        = var.region
  ip_cidr_range = "10.0.1.0/24"
  network       = google_compute_network.vpc.id
}