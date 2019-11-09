data "google_compute_zones" "available" {
  region = var.region
}

resource "google_compute_network" "gke_network" {
  name                    = "gke-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "gke_subnetwork" {
  name                     = "gke-subnetwork"
  region                   = var.region
  network                  = google_compute_network.gke_network.self_link
  ip_cidr_range            = cidrsubnet(var.network, 4, 0)
  private_ip_google_access = true

  secondary_ip_range {
    ip_cidr_range = cidrsubnet(var.network, 4, 1)
    range_name    = local.pod_subnet_range
  }

  secondary_ip_range {
    ip_cidr_range = cidrsubnet(var.network, 4, 2)
    range_name    = local.service_subnet_range
  }
}

resource "google_container_node_pool" "node_pool_1" {
  cluster = google_container_cluster.primary.name
  location = data.google_compute_zones.available.names[0]
  initial_node_count = 2

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
    max_node_count = 4
    min_node_count = 2
  }

  management {
    auto_repair = true
    auto_upgrade = true
  }

  timeouts {
    create = "30m"
    delete = "30m"
  }
}

resource "google_container_cluster" "primary" {
  provider = "google-beta"
  name     = "kube-cluster-1"
  location = data.google_compute_zones.available.names[0]

  initial_node_count = 1
  remove_default_node_pool = true
  network            = google_compute_network.gke_network.name
  subnetwork         = google_compute_subnetwork.gke_subnetwork.name

  ip_allocation_policy {
    cluster_secondary_range_name  = local.pod_subnet_range
    services_secondary_range_name = local.service_subnet_range
  }

  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = true
    }
  }

  provisioner "local-exec" {
    when = "destroy"
    command = "sleep 90"
  }
}

resource "null_resource" "dependency_setter" {
  provisioner "local-exec" {
    command = "sleep 60"
  }

  triggers = {
    cluster_id = google_container_cluster.primary.id
  }

  depends_on = [
    google_container_cluster.primary,
    google_container_node_pool.node_pool_1
  ]
}
