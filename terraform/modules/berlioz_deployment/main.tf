resource "kubernetes_deployment" "app" {
  metadata {
    name = "app"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "app"
      }
    }
    template {
      metadata {
        labels = {
          app = "app"
        }
      }
      spec {
        init_container {
          name = "initdb"
          image = "arey/mysql-client"
          command = ["/bin/sh", "-c"]
          args = ["mysql -h$(MYSQL_HOST) -u$(MYSQL_USER) -p$(MYSQL_PASSWORD) < /dump/init.sql"]

          volume_mount {
            mount_path = "/dump"
            name = "dump"
          }

          env_from {
            config_map_ref {
              name = kubernetes_config_map.sql_conn.metadata[0].name
            }
          }
        }

        container {
          name = "app"
          image = var.app_image

          env_from {
            config_map_ref {
              name = kubernetes_config_map.sql_conn.metadata[0].name
            }
          }
        }

        volume {
          name = "dump"
          config_map {
            name = kubernetes_config_map.sql_dump.metadata[0].name
            items {
              key = "init.sql"
              path = "init.sql"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_deployment" "web" {
  metadata {
    name = "web"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "web"
      }
    }
    template {
      metadata {
        labels = {
          app = "web"
        }
      }
      spec {
        container {
          name = "web"
          image = var.web_image

          env {
            name = "APP_HOST"
            value = kubernetes_service.app.metadata[0].name
          }

          env {
            name = "APP_PORT"
            value = kubernetes_service.app.spec[0].port[0].port
          }
        }
      }
    }
  }
}
