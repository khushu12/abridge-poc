resource "google_compute_network" "vpc" {
  name                    = var.vpc_name
  auto_create_subnetworks = false
  project                 = var.project_id
}

resource "google_compute_subnetwork" "public" {
  name          = var.public_subnet_name
  ip_cidr_range = var.public_subnet_cidr
  network       = google_compute_network.vpc.id
  region        = var.region
  project       = var.project_id
}

resource "google_compute_subnetwork" "private_1" {
  name          = var.private_subnet_1_name
  ip_cidr_range = var.private_subnet_1_cidr
  network       = google_compute_network.vpc.id
  region        = var.region
  project       = var.project_id

  private_ip_google_access = true
}

resource "google_compute_subnetwork" "private_2" {
  name          = var.private_subnet_2_name
  ip_cidr_range = var.private_subnet_2_cidr
  network       = google_compute_network.vpc.id
  region        = var.region
  project       = var.project_id

  private_ip_google_access = true
}

resource "google_compute_router" "router" {
  name    = var.nat_router_name
  region  = var.region
  network = google_compute_network.vpc.id
  project = var.project_id
}

resource "google_compute_router_nat" "nat" {
  name                               = var.nat_name
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  project                            = var.project_id

  subnetwork {
    name                    = google_compute_subnetwork.private_1.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  subnetwork {
    name                    = google_compute_subnetwork.private_2.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}

# Firewall rule to allow HTTPS (port 443) traffic to GKE
resource "google_compute_firewall" "allow_https_to_gke" {
  name    = "allow-https-to-gke"
  network = google_compute_network.vpc.id
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  # Target all instances with the gke tag
  target_tags = ["gke"]

  # Allow traffic from anywhere to GKE nodes
  source_ranges = ["0.0.0.0/0"]
}
