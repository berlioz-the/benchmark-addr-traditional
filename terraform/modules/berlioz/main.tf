resource "null_resource" "dependency_getter" {
  provisioner "local-exec" {
    command = "echo ${length(var.dependencies)}"
  }
}

resource "kubernetes_namespace" "berlioz_namespace" {
  metadata {
    name = var.namespace
    labels = {
      istio-injection = "enabled"
    }
  }
}

resource "kubernetes_secret" "database_secrets" {
  metadata {
    name = "database-secrets"
    namespace = kubernetes_namespace.berlioz_namespace.metadata[0].name
  }
  data = {
    MYSQL_HOST = var.mysql_address
    MYSQL_USER = var.mysql_user
    MYSQL_PASSWORD = var.mysql_password
    MYSQL_DATABASE = var.mysql_database
  }
}

