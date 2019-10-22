locals {
  pods_subnet_range     = "gke-pods"
  services_subnet_range = "gke-services"
}

resource "google_compute_network" "gke_network" {
  name                    = "gke-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "gke_subnetwork" {
  name                     = "gke-subnetwork"
  region                   = var.region
  network                  = google_compute_network.gke_network.self_link
  ip_cidr_range            = "10.128.0.0/20"
  private_ip_google_access = true

  secondary_ip_range {
    ip_cidr_range = "10.0.0.0/16"
    range_name    = local.pods_subnet_range
  }

  secondary_ip_range {
    ip_cidr_range = "10.1.0.0/16"
    range_name    = local.services_subnet_range
  }
}

resource "google_container_node_pool" "node_pool_1" {
  cluster = google_container_cluster.primary.name
  location = "${var.region}-a"
  initial_node_count = 1

  node_config {
    metadata = {
      disable-legacy-endpoints = true
    }
    machine_type = var.instance_type

    oauth_scopes = [
      "https://www.googleapis.com/auth/devstorage.read_write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/logging.write",
    ]
  }

  autoscaling {
    max_node_count = 3
    min_node_count = 1
  }

  management {
    auto_repair = true
    auto_upgrade = true
  }
}

resource "google_container_cluster" "primary" {
  provider = "google-beta"
  name     = "kube-cluster-1"
  location = "${var.region}-a"

  initial_node_count = 1
  remove_default_node_pool = true
  network            = google_compute_network.gke_network.name
  subnetwork         = google_compute_subnetwork.gke_subnetwork.name

  ip_allocation_policy {
    cluster_secondary_range_name  = local.pods_subnet_range
    services_secondary_range_name = local.services_subnet_range
  }

  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = true
    }
  }

  istio_config {
    disabled = false
    auth = "AUTH_MUTUAL_TLS"
  }
}
