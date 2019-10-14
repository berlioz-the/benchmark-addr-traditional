provider "google" {
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
  instance_name = "berlioz"
  database_name = "berlioz"
}
