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

data "helm_repository" "istio_release" {
  name = "istio.io"
  url = "https://storage.googleapis.com/istio-release/releases/1.3.4/charts/"
}

resource "helm_release" "istio_init" {
  name = "istio-init"
  chart = "istio.io/istio-init"
  namespace = "istio-system"
  repository = data.helm_repository.istio_release.metadata[0].name
  wait = true
  timeout = 1200
  depends_on = [null_resource.dependency_getter]
  provisioner "local-exec" {
    when = "destroy"
    command = "sleep 180"
  }
}

resource "null_resource" "wait_crd" {
  provisioner "local-exec" {
    command = "sleep 60"
  }
  triggers = {
    istio_init_id = helm_release.istio_init.id
  }
  depends_on = [helm_release.istio_init]
}

resource "helm_release" "istio" {
  name = "istio"
  chart = "istio.io/istio"
  namespace = "istio-system"
  repository = data.helm_repository.istio_release.metadata[0].name
  depends_on = [null_resource.wait_crd]
  wait = false

  values = [
    file("${path.module}/files/values-istio-demo.yaml")
  ]

  set {
    name = "gateways.istio-ingressgateway.loadBalancerIP"
    value = var.gateway_address
  }
}

resource "null_resource" "wait_istio" {
  triggers = {
    istio_id = helm_release.istio.id
  }
  provisioner "local-exec" {
    command = "sleep 120"
  }
}

resource "helm_release" "berlioz" {
  chart = "${path.root}/../charts/berlioz"
  name = "berlioz"
  namespace = kubernetes_namespace.berlioz_namespace.metadata[0].name
  depends_on = [null_resource.wait_istio]

  set {
    name = "database.secretName"
    value = kubernetes_secret.database_secrets.metadata[0].name
  }

  set {
    name = "backend.image"
    value = var.web_image
  }

  set {
    name = "frontend.image"
    value = var.web_image
  }
}
