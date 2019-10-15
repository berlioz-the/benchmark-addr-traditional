resource "google_compute_global_address" "berlioz_address" {
  name = "berioz-address"
}

resource "kubernetes_ingress" "berlioz_ingress" {
  metadata {
    name = "berlioz-ingress"
    annotations = {
      "kubernetes.io/ingress.global-static-ip-name" = "berioz-address"
    }
  }
  spec {
    backend {
      service_name = kubernetes_service.web.metadata[0].name
      service_port = kubernetes_service.web.spec[0].port[0].target_port
    }
  }

  depends_on = [kubernetes_service.web]
}
