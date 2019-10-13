variable "machine_type" {
  default = "db-f1-micro"
}

variable "gcp_project_id" {}

variable "instance_name" {
  default = "berlioz_sql_instance"
}

variable "database_name" {
  default = "berliozdb"
}

variable "database_user" {
  default = "berlioz"
}
