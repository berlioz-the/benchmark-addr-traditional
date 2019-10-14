resource "kubernetes_service" "app" {
  metadata {
    name = "app"
  }

  spec {
    selector = {
      app = "app"
    }
    type = "NodePort"
    port {
      protocol    = "TCP"
      port        = 4000
      target_port = 4000
    }
  }
}

resource "kubernetes_service" "web" {
  metadata {
    name = "web"
    annotations = {
      "cloud.google.com/neg" = "{\"ingress\": true}"
    }
  }

  spec {
    selector = {
      app = "web"
    }
    type = "NodePort"
    port {
      protocol    = "TCP"
      port        = 3000
      target_port = 3000
    }
  }

  lifecycle {
    ignore_changes = [metadata[0].annotations]
  }
}
