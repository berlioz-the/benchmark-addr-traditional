output "ip" {
  value = google_compute_address.istio_gateway_address.address
}
