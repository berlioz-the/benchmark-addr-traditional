provider "null" {}

resource "null_resource" "dependency_getter" {
  provisioner "local-exec" {
    command = "echo ${length(var.dependencies)}"
  }
}

provider "kubernetes" {
  load_config_file       = false
  host                   = var.gke_endpoint
  token                  = var.access_token
  cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
}

resource "kubernetes_service_account" "tiller" {
  metadata {
    name = "tiller"
    namespace = "kube-system"
  }
  depends_on = [null_resource.dependency_getter]
}

resource "kubernetes_cluster_role_binding" "tiller" {
  metadata {
    name = "tiller"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind = "ClusterRole"
    name = "cluster-admin"
  }
  subject {
    kind = "ServiceAccount"
    name = kubernetes_service_account.tiller.metadata[0].name
    namespace = "kube-system"
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

provider "helm" {
  service_account = kubernetes_service_account.tiller.metadata[0].name
  install_tiller = true
  tiller_image = "gcr.io/kubernetes-helm/tiller:v2.15.2"

  kubernetes {
    load_config_file       = false
    host                   = var.gke_endpoint
    token                  = var.access_token
    cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
  }
}
