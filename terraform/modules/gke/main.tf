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

resource "google_container_cluster" "primary" {
  name     = "kube-cluster-1"
  location = "${var.region}-a"

  initial_node_count = 1
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

//  lifecycle {
//    ignore_changes = [master_auth,
//      network,
//      subnetwork,
//      node_config
//    ]
//    https://github.com/hashicorp/terraform/issues/21433
//    ignore_changes = all
//    prevent_destroy = true
//  }
}
