provider "google" {
  project = var.project
  zone    = var.zone
}

provider "google-beta" {
  project = var.project
  zone    = var.zone
}

provider "godaddy" {}

locals {
    services = {
        fabiolb = {
            paths = ["/"]
            port = 9999
        }

        nomad = {
            paths = ["/ui/", "/v1/"]
            port = 4646
        }
    }
}

resource "google_compute_instance_template" "default" {
  name_prefix = "hashi-client"
  description = var.desc

  disk {
    source_image = var.machine_image
    auto_delete  = true
    boot         = true
  }

  tags         = var.tags
  labels       = var.labels
  machine_type = var.machine_type

  network_interface {
    network = var.network_name
    access_config {
      nat_ip       = ""
      network_tier = var.network_tier
    }
  }

  service_account {
    email  = var.account_email
    scopes = var.account_scopes
  }

  lifecycle {
    create_before_destroy = true
  }

  metadata_startup_script = "${file("${path.module}/${var.startup_script_path}")}"
}

resource "google_compute_global_address" "global_ip" {
  name = "global-address"
}

resource "google_compute_instance_group_manager" "default" {
  provider           = "google-beta"
  base_instance_name = "hashi-client"
  name               = "hashi-client-group-manager"
  target_size        = var.target_size

  update_policy {
    type = "PROACTIVE"
    minimal_action = "REPLACE"
    min_ready_sec = 120
  }

  version {
    name              = var.environment
    instance_template = google_compute_instance_template.default.self_link
  }

  wait_for_instances = true

  dynamic "named_port" {
      for_each = local.services
      content {
          name = named_port.key
          port = named_port.value["port"]
      }
  }
}

resource "google_compute_managed_ssl_certificate" "client_cert" {
  provider = "google-beta"
  count = length(var.domains)

  name = "${split(".", var.domains[count.index])[0]}-cert"

  managed {
    domains = ["${var.domains[count.index]}"]
  }
}

resource "godaddy_domain_record" "default" {
  count = length(var.domains)
  domain      = var.domains[count.index]
  addresses   = [google_compute_global_address.global_ip.address]
  nameservers = ["ns13.domaincontrol.com", "ns14.domaincontrol.com"]
}

resource "google_compute_health_check" "services" {
  for_each     = local.services
  name         = each.key

  http_health_check {
    port = each.value["port"]
    request_path = each.value["paths"][0]
 }
}

resource "google_compute_backend_service" "services" {
  for_each      = local.services
  name          = each.key
  health_checks = [google_compute_health_check.services[each.key].self_link]
  port_name     = each.key
  protocol      = "HTTP"
  backend {
    group = "${google_compute_instance_group_manager.default.instance_group}"
  }
}

resource "google_compute_url_map" "services" {
  name            = "service-map"
  default_service = google_compute_backend_service.services["fabiolb"].self_link

  host_rule {
    hosts        = ["*"]
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = google_compute_backend_service.services["fabiolb"].self_link

    dynamic "path_rule" {
        for_each = local.services
        content {
            paths = formatlist("%s*", path_rule.value["paths"])
            service = google_compute_backend_service.services[path_rule.key].self_link
        }
    }
  }
}

resource "google_compute_target_https_proxy" "default" {
  name             = "default-https-proxy"
  url_map          = google_compute_url_map.services.self_link
  ssl_certificates = google_compute_managed_ssl_certificate.client_cert.*.self_link
}

resource "google_compute_global_forwarding_rule" "default" {
  name       = "default-global-rule"
  target     = google_compute_target_https_proxy.default.self_link
  ip_address = google_compute_global_address.global_ip.address
  port_range = "443"
}

output "global_ip" {
  value = "${google_compute_global_address.global_ip.address}"
}
