job "vault" {
  datacenters = ["dc1"]

    group "vault" {
        count = 1

        update {
            max_parallel = 2
            min_healthy_time = "30s"
            healthy_deadline = "5m"
            auto_revert = true
        }

        restart {
            attempts = 3
            delay    = "30s"
        }

        task "vault" {
            driver = "docker"
            config {
                image = "vault"
                network_mode = "host"
                command = "server"
            }

            env {
                VAULT_LOCAL_CONFIG = <<EOF
                    ui = true
                    api_addr = "http://${NOMAD_IP_lb}:8200"
                    disable_mlock = true

                    storage "gcs" {
                        bucket = "c9s-vault"
                        ha_enabled = "true"
                    }

                    listener "tcp" {
                        address     = "0.0.0.0:8200"
                        tls_disable = 1
                    }

                    seal "gcpckms" {
                        project     = "${project}"
                        region      = "global"
                        key_ring    = "vault"
                        crypto_key  = "vault-key"
                    }    
                EOF
                VAULT_ADDR = "http://0.0.0.0:8200"
            }

            resources {
                network {
                    port "lb" { 
                        static = 8200
                    }
                }
            }
        }
    }
}