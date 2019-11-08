data "google_compute_network" "gke_network" {
  name = var.network
}

resource "google_compute_global_address" "sql_peering_address" {
  provider      = "google-beta"
  name          = "sql-peering-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = data.google_compute_network.gke_network.self_link
}

resource "google_service_networking_connection" "sql_peering_connection" {
  provider                = "google-beta"
  network                 = data.google_compute_network.gke_network.self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.sql_peering_address.name]
}

resource "google_sql_database_instance" "master" {
  database_version = "MYSQL_5_7"
  settings {
    tier = var.machine_type

    backup_configuration {
      binary_log_enabled = true
      enabled            = true
      start_time         = "01:00"
    }

    ip_configuration {
      ipv4_enabled    = true
      private_network = data.google_compute_network.gke_network.self_link
      require_ssl = false
    }
  }

  depends_on = [
    google_service_networking_connection.sql_peering_connection
  ]
}

resource "google_sql_ssl_cert" "client_cert" {
  common_name = "client-cert"
  instance = google_sql_database_instance.master.name
}

resource "google_sql_database" "db" {
  instance = google_sql_database_instance.master.name
  name = var.database_name
}

resource "random_string" "user_password" {
  length           = 16
  special          = true
  override_special = "_@-%#!"
}

resource "google_sql_user" "sql_user" {
  name     = var.database_user
  instance = google_sql_database_instance.master.name
  host     = "%"
  password = random_string.user_password.result
}
