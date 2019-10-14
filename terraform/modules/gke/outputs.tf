output "cluster_ca_certificate" {
  value = google_container_cluster.primary.master_auth[0].cluster_ca_certificate
}

output "endpoint" {
  value = google_container_cluster.primary.endpoint
}

output "network" {
  value = google_compute_network.gke_network.name
}
