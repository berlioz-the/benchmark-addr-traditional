resource "google_sql_database_instance" "master" {
  name = var.instance_name
  database_version = "MYSQL_5_7"
  settings {
    tier = var.machine_type

    backup_configuration {
      binary_log_enabled = true
      enabled            = true
      start_time         = "01:00"
    }

//    ip_configuration {
//      authorized_networks {
//
//      }
//    }
  }
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
