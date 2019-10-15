terraform {
    # The latest version of Terragrunt (v0.19.0 and above) requires Terraform 0.12.0 or above.
    required_version = ">= 0.12.0"
}

provider "godaddy" {}

provider "google" {
  project = var.project
  zone    = var.zone
}

provider "google-beta" {
  project = var.project
  zone    = var.zone
}