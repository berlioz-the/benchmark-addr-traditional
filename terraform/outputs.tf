//output "http_address" {
//  value = "http://${module.berlioz_deployment.ip_address}"
//}
output "ip" {
  value = google_compute_address.istio_gateway_address.address
}

output "address" {
  value = module.cloudsql.private_ip_address
}

output "user" {
  value = module.cloudsql.user_name
}

output "password" {
  value = module.cloudsql.password
}

output "database" {
  value = module.cloudsql.database_name
}

//output "private_key" {
//  value = module.cloudsql.private_key
//}
//
//output "server_ca_cert" {
//  value = module.cloudsql.server_ca_cert
//}
//
//output "cert" {
//  value = module.cloudsql.cert
//}
