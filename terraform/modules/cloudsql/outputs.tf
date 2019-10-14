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
