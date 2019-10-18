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
        # 4646-4647 = Nomad
        # 8200 - 8201 = Vault
        # 8300 - 8302, 8500 = Consul 
        # 9998 - 9999 = Fabio
        ports    = ["22", "80", "443", "4646-4647", "8200-8201", "8300-8302", "8500", "8600", "9998", "9999"]
    }

    allow {
        protocol = "udp"
        ports    = ["443", "8300-8302", "8500", "8600"]
    }
}