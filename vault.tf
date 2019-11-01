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

resource "google_storage_bucket" "vault" {
  name     = var.vault_bucket_name
  location = "US"
}
