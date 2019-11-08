provider "google" {
  project   = var.gcp_project_id
  region    = var.gcp_region
}

provider "google-beta" {
  project   = var.gcp_project_id
  region    = var.gcp_region
}

provider "random" {}

module "gke" {
  source = "./modules/gke"
  region = var.gcp_region
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

data "google_client_config" "default" {}

module "berlioz" {
  source = "./modules/berlioz"
  gateway_address = google_compute_address.istio_gateway_address.address
  gke_endpoint = module.gke.endpoint
  access_token = data.google_client_config.default.access_token
  cluster_ca_certificate = module.gke.cluster_ca_certificate
  dependencies = [module.gke.depended_on]
  mysql_address = module.cloudsql.private_ip_address
  mysql_user = module.cloudsql.user_name
  mysql_password = module.cloudsql.password
  mysql_database = module.cloudsql.database_name
}
