output "http_address" {
  value = "http://${module.berlioz_deployment.ip_address}"
}
