variable "machine_type" {
  default = "db-f1-micro"
}

variable "gcp_project_id" {}

variable "database_name" {
  default = "berliozdb"
}

variable "database_user" {
  default = "berlioz"
}

variable "network" {}
