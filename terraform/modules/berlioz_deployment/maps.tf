resource "kubernetes_config_map" "sql_dump" {
  metadata {
    name = "sql-dump"
  }

  data = {
    "init.sql" = file("${path.module}/files/init.sql")
  }
}

resource "kubernetes_config_map" "sql_conn" {
  metadata {
    name = "sql-conn"
  }

  data = {
    "MYSQL_HOST" = var.mysql_host
    "MYSQL_USER"  = var.mysql_user
    "MYSQL_PASSWORD" = var.mysql_password
  }
}
