resource "google_compute_global_address" "berlioz_address" {
  name = "berioz-address"
}

resource "google_compute_managed_ssl_certificate" "berlioz_ssl_certificate" {
  provider = "google-beta"
  name     = "berlioz-ssl-certificate"
  count    = var.https_hostname == "" ? 0 : 1

  managed {
    domains = [var.https_hostname == "" ? "dummy" : var.https_hostname]
  }

}

resource "kubernetes_ingress" "berlioz_ingress" {
  metadata {
    name = "berlioz-ingress"
    namespace = kubernetes_namespace.berlioz.metadata[0].name
    annotations = {
      "kubernetes.io/ingress.global-static-ip-name" = "berioz-address"
      "ingress.gcp.kubernetes.io/pre-shared-cert" = var.https_hostname == "" ? null : "berlioz-ssl-certificate"
      "kubernetes.io/ingress.allow-http": var.https_hostname == "" ? true : false
    }
  }
  spec {
    backend {
      service_name = kubernetes_service.web.metadata[0].name
      service_port = kubernetes_service.web.spec[0].port[0].target_port
    }
  }

  depends_on = [kubernetes_service.web, google_compute_managed_ssl_certificate.berlioz_ssl_certificate]
}
