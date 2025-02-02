resource "google_storage_bucket" "terraform_state" {
  name          = var.bucket_name
  location      = var.region
  force_destroy = true

  versioning {
    enabled = true
  }
}
  
# Create VPC
resource "google_compute_network" "vpc" {
  name                    = "var.vpc_name"
  auto_create_subnetworks = false
}

# Create Subnets
resource "google_compute_subnetwork" "public_subnet_1" {
  name          = var.public_subnet1
  network       = google_compute_network.vpc.id
  region        = var.region
  ip_cidr_range = "10.0.1.0/24"
}

resource "google_compute_subnetwork" "public_subnet_2" {
  name          = var.public_subnet2
  network       = google_compute_network.vpc.id
  region        = var.region
  ip_cidr_range = "10.0.2.0/24"
}

resource "google_compute_subnetwork" "private_subnet_1" {
  name          = var.private_subnet1
  network       = google_compute_network.vpc.id
  region        = var.region
  ip_cidr_range = "10.0.3.0/24"
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "private_subnet_2" {
  name          = var.private_subnet2
  network       = google_compute_network.vpc.id
  region        = var.region
  ip_cidr_range = "10.0.4.0/24"
  private_ip_google_access = true
}

# Create GKE Cluster
resource "google_container_cluster" "gke" {
  name                  = var.cluster_name
  location              = var.region
  network               = google_compute_network.vpc.id
  subnetwork            = google_compute_subnetwork.private_subnet_1.id
  remove_default_node_pool = true
}

resource "google_container_node_pool" "private_nodes" {
  name       = var.node_pool_name
  cluster    = google_container_cluster.gke.id
  location   = var.region
  node_count = 2

  node_config {
    machine_type    = var.machine_type
    service_account = var.gke_service_account
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
    tags         = ["gke-node"]
  }
}

# Firewall rule to allow internal communication within the VPC
resource "google_compute_firewall" "allow_internal" {
  name    = "allow-internal"
  network = google_compute_network.vpc.id

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  source_ranges = ["10.0.0.0/16"]
}

# Firewall rule to allow external access to the application
resource "google_compute_firewall" "allow_http" {
  name    = "allow-gke-http"
  network = google_compute_network.vpc.id

  allow {
    protocol = "tcp"
    ports    = ["80", "443", "8080"]
  }

  source_ranges = ["0.0.0.0/0"]
}

# Firewall rule to allow Load Balancer to access GKE nodes
resource "google_compute_firewall" "allow_lb" {
  name    = "allow-lb-to-nodes"
  network = google_compute_network.vpc.id

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["gke-node"]
}

# NAT Gateway for Private Subnets
resource "google_compute_router" "router" {
  name    = "nat-router"
  network = google_compute_network.vpc.id
  region  = var.region
}

resource "google_compute_router_nat" "nat" {
  name                               = "nat-config"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
