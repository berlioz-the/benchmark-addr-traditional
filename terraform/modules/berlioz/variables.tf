variable "gateway_address" {
  default = ""
}

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

variable "app_image" {}

variable "web_image" {}
