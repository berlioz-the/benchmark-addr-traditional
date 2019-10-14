resource "kubernetes_ingress" "berlioz_ingress" {
  metadata {
    name = "berlioz-ingress"
  }
  spec {
    backend {
      service_name = kubernetes_service.web.metadata[0].name
      service_port = kubernetes_service.web.spec[0].port[0].target_port
    }
  }

  depends_on = [kubernetes_service.web]
}
