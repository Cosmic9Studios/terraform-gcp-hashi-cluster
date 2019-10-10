
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

resource "google_compute_instance_template" "client" {
  name_prefix = "hashi-client"
  description = "Created with Terraform"

  disk {
    source_image = "${var.project}/hashi-client-${data.archive_file.init.output_md5}"
    auto_delete  = true
    boot         = true
  }

  tags         = var.tags
  machine_type = var.client_machine_type

  network_interface {
    network = google_compute_network.default.name
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

  metadata_startup_script = <<EOT
    sudo pm2 start /scripts/nomad.sh --wait-ready --listen-timeout 15000
    sudo pm2 start /scripts/consul.sh --wait-ready --listen-timeout 15000
  EOT

  depends_on = [null_resource.packer_build]
}

resource "google_compute_global_address" "global_ip" {
  name = "global-address"
}

resource "google_compute_instance_group_manager" "client" {
  provider           = "google-beta"
  base_instance_name = "hashi-client"
  name               = "hashi-client-group-manager"
  target_size        = var.client_target_size

  update_policy {
    type = "PROACTIVE"
    minimal_action = "REPLACE"
    min_ready_sec = 120
    max_unavailable_fixed = 1
    max_surge_fixed = 1
  }

  version {
    name              = "default"
    instance_template = google_compute_instance_template.client.self_link
  }

  wait_for_instances = true

  dynamic "named_port" {
      for_each = local.services
      content {
          name = named_port.key
          port = named_port.value["port"]
      }
  }

  depends_on = [google_compute_instance_group_manager.server]
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

  record {
    name = "www"
    type = "CNAME"
    data = "@"
    ttl = 3600
    priority = 0
  }

  record {
    name = "_domainconnect"
    type = "CNAME"
    data = "_domainconnect.gd.domaincontrol.com"
    ttl = 3600
    priority = 0
  }
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
    group = "${google_compute_instance_group_manager.client.instance_group}"
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

resource "google_compute_target_http_proxy" "http" {
  name        = "http-target-proxy"
  url_map     = google_compute_url_map.services.self_link
}

resource "google_compute_global_forwarding_rule" "default" {
  name       = "default-global-rule"
  target     = google_compute_target_https_proxy.default.self_link
  ip_address = google_compute_global_address.global_ip.address
  port_range = "443"
}

resource "google_compute_global_forwarding_rule" "http" {
  name       = "http-global-rule"
  target     = google_compute_target_http_proxy.http.self_link
  ip_address = google_compute_global_address.global_ip.address
  port_range = "80"
}

output "global_ip" {
  value = "${google_compute_global_address.global_ip.address}"
}
