job "fabio" {
  datacenters = ["dc1"]
  type = "system"

    group "fabio" {

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

        task "fabio" {
            driver = "docker"
            config {
                image = "fabiolb/fabio"
                network_mode = "host"
            }

            resources {
                cpu    = 200
                memory = 128
                network {
                    mbits = 20
                    port "lb" { 
                        static = 9999
                    }
                    port "ui" {
                        static = 9998
                    }
                }
            }
        }
    }
}