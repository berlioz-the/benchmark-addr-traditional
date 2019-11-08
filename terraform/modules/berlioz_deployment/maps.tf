resource "kubernetes_config_map" "sql_dump" {
  metadata {
    name = "sql-dump"
    namespace = "berlioz"
  }

  data = {
    "init.sql" = file("${path.module}/files/init.sql")
  }
}

resource "kubernetes_config_map" "sql_conn" {
  metadata {
    name = "sql-conn"
    namespace = "berlioz"
  }

  data = {
    "MYSQL_HOST" = var.mysql_host
    "MYSQL_USER"  = var.mysql_user
  }
}

resource "kubernetes_secret" "mysql_password" {
  metadata {
    name = "mysql"
    namespace = "berlioz"
  }
  data = {
    "MYSQL_PASSWORD" = var.mysql_password
  }
}
