resource "kubernetes_config_map" "sql_dump" {
  metadata {
    name = "sql-dump"
    namespace = kubernetes_namespace.berlioz.metadata[0].name
  }

  data = {
    "init.sql" = file("${path.module}/files/init.sql")
  }
}

resource "kubernetes_config_map" "sql_conn" {
  metadata {
    name = "sql-conn"
    namespace = kubernetes_namespace.berlioz.metadata[0].name
  }

  data = {
    "MYSQL_HOST" = var.mysql_host
    "MYSQL_USER"  = var.mysql_user
  }
}

resource "kubernetes_secret" "mysql_password" {
  metadata {
    generate_name = "mysql-"
    namespace = kubernetes_namespace.berlioz.metadata[0].name
  }
  data = {
    "MYSQL_PASSWORD" = var.mysql_password
  }
}
