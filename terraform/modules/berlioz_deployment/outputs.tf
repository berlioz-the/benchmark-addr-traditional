output "http_address" {
  value = kubernetes_ingress.berlioz_ingress.load_balancer_ingress[0].ip
}
