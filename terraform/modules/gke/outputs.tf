output "network_link" {
  value = google_compute_network.gke_network.ipv4_range
}

output "cluster_ca_certificate" {
  value = google_container_cluster.primary.master_auth[0].cluster_ca_certificate
}
