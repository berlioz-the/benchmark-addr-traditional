output "private_ip_address" {
  value = google_sql_database_instance.master.private_ip_address
}

output "database_name" {
  value = google_sql_database.db.name
}

output "user_name" {
  value = google_sql_user.sql_user.name
}

output "password" {
  value = google_sql_user.sql_user.password
}

output "private_key" {
  value = google_sql_ssl_cert.client_cert.private_key
}

output "server_ca_cert" {
  value = google_sql_ssl_cert.client_cert.server_ca_cert
}

output "cert" {
  value = google_sql_ssl_cert.client_cert.cert
}
