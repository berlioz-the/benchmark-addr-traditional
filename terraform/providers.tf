data "google_client_config" "default" {}

provider "google" {
  project   = var.gcp_project_id
  region    = var.gcp_region
}

provider "google-beta" {
  project   = var.gcp_project_id
  region    = var.gcp_region
}

provider "random" {}

provider "null" {}

provider "kubernetes" {
  load_config_file       = false
  host                   = module.gke.endpoint
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.cluster_ca_certificate)
}

resource "kubernetes_service_account" "tiller" {
  metadata {
    name = "tiller"
    namespace = "kube-system"
  }
  depends_on = [module.gke.depended_on]
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

provider "helm" {
  service_account = "tiller"
  install_tiller = true
  tiller_image = "gcr.io/kubernetes-helm/tiller:v2.15.2"

  kubernetes {
    load_config_file       = false
    host                   = module.gke.endpoint
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(module.gke.cluster_ca_certificate)
  }
}
