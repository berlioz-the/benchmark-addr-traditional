variable "gateway_address" {
  default = ""
}

variable "gke_endpoint" {}

variable "access_token" {}

variable "cluster_ca_certificate" {}

variable "namespace" {
  default = "berlioz"
}

variable "dependencies" {
  type = "list"
  default = []
}

variable "mysql_address" {}

variable "mysql_user" {}

variable "mysql_password" {}

variable "mysql_database" {}
