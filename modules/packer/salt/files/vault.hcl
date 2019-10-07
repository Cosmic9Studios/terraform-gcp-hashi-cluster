ui = true

storage "consul" {
  address = "0.0.0.0:8500"
  path = "vault/"
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = 1
}

seal "gcpckms" {
  region      = "global"
  key_ring    = "vault"
  crypto_key  = "vault-key"
}

disable_mlock = true