
terraform {
  # The latest version of Terragrunt (v0.19.0 and above) requires Terraform 0.12.0 or above.
  required_version = ">= 0.12.0"
}

resource "google_compute_network" "default" {
  name = var.network_name
  project = var.project
}

resource "google_compute_firewall" "firewall" {
  name    = var.firewall_name
  project = var.project
  network = google_compute_network.default.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443", "8300-8301", "8500", "8600", "4646-4647", "8080", "9998", "9999", "5000", "20000-32000"]
  }

  allow {
    protocol = "udp"
    ports    = ["443", "8300-8301", "8500", "8600"]
  }
}


module "packer" { 
    source = "./modules/packer"
    project = var.project
    ssh_username = var.ssh_username
}


module "servers" {
  source = "./modules/server"
  name         = "server"
  project      = var.project
  network_name = google_compute_network.default.name
  account_email = var.account_email
  machine_image = module.packer.server_image
}

module "clients" {
  source = "./modules/client"
  domains      = var.domains
  project      = var.project
  network_name = google_compute_network.default.name
  account_email = var.account_email
  machine_image = module.packer.client_image
}

# Auto unseal for Vault
resource "google_kms_key_ring" "key_ring" {
    project  = var.project
    name     = "vault"
    location = "global"
}

resource "google_kms_crypto_key" "crypto_key" {
    name            = "vault-key"
    key_ring        = "${google_kms_key_ring.key_ring.self_link}"
    rotation_period = "100000s"
}