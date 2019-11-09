module "gke" {
  source = "./modules/gke"

  region = var.gcp_region
  instance_type = var.gke_instance_type
}

module "cloudsql" {
  source = "./modules/cloudsql"
  gcp_project_id = var.gcp_project_id
  database_name = "demo"
  network = module.gke.network
}

resource "google_compute_address" "istio_gateway_address" {
  name = "istio-gateway-address"
  address_type = "EXTERNAL"
}

module "berlioz" {
  source = "./modules/berlioz"

  gateway_address = google_compute_address.istio_gateway_address.address
  dependencies = [module.gke.depended_on, kubernetes_cluster_role_binding.tiller.id]
  mysql_address = module.cloudsql.private_ip_address
  mysql_user = module.cloudsql.user_name
  mysql_password = module.cloudsql.password
  mysql_database = module.cloudsql.database_name
  app_image = var.app_image
  web_image = var.web_image
}
