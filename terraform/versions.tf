terraform {
  required_version = ">= 0.12"
  backend "gcs" {
    bucket      = "terraform-berlioz-state"
    prefix      = "terraform/state"
  }
}
