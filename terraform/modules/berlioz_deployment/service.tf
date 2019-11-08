//resource "kubernetes_service" "app" {
//  metadata {
//    name = "app"
//    namespace = kubernetes_namespace.berlioz.metadata[0].name
//  }
//
//  spec {
//    selector = {
//      app = "app"
//    }
//    type = "NodePort"
//    port {
//      protocol    = "TCP"
//      port        = 4000
//      target_port = 4000
//    }
//  }
//}
//
//resource "kubernetes_service" "web" {
//  metadata {
//    name = "web"
//    namespace = kubernetes_namespace.berlioz.metadata[0].name
////    annotations = {
////      "cloud.google.com/neg" = "{\"ingress\": true}"
////    }
//  }
//
//  spec {
//    selector = {
//      app = "web"
//    }
//    type = "NodePort"
//    port {
//      protocol    = "TCP"
//      port        = 3000
//      target_port = 3000
//    }
//  }
//
//  lifecycle {
//    ignore_changes = [metadata[0].annotations]
//  }
//}
