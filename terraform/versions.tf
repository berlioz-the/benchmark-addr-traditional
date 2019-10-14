terraform {
  required_version = ">= 0.12"
  backend "gcs" {
    bucket      = "123123123-terraform-berlioz-state"
    prefix      = "terraform/state"
  }
}
