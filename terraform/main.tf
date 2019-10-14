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

data "google_client_config" "default" {}

provider "kubernetes" {
  load_config_file       = false
  host                   = module.gke.endpoint
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.cluster_ca_certificate)
}

module "berlioz_deployment" {
  source = "./modules/berlioz_deployment"
  mysql_host = module.cloudsql.private_ip_address
  mysql_user = module.cloudsql.user_name
  mysql_password = module.cloudsql.password
  app_image = var.app_image
  web_image = var.web_image
}
