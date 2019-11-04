
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

        vault = {
            paths = ["/ui/vault"]
            port = 8200
        }

        consul = {
            paths = ["/consul/"]
            port = 8500
        }
    }

    domains = concat(
        [for domain in var.domains : "${join(".", compact([var.subdomain, domain]))}"],
        [for domain in var.domains : "${join(".", compact(["nomad", var.subdomain, domain]))}"],
        [for domain in var.domains : "${join(".", compact(["consul", var.subdomain, domain]))}"],
        [for domain in var.domains : "${join(".", compact(["vault", var.subdomain, domain]))}"]
    )
}

resource "google_compute_instance_template" "client" {
  name_prefix = "hashi-client"
  description = "Created with Terraform"

  disk {
    source_image = "${var.project}/${data.external.run_packer.result["client"]}"
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
  count = length(local.domains)

  name = replace(local.domains[count.index], ".", "-")

  managed {
    domains = ["${local.domains[count.index]}"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "godaddy_domain_record" "default" {
  count = length(var.domains)
  domain      = var.domains[count.index]

  record {
    name = "www"
    type = "CNAME"
    data = "@"
    ttl = 3600
    priority = 0
  }

  record {
    name = coalesce(var.subdomain, "@")
    type = "A"
    data = "${google_compute_global_address.global_ip.address}"
    ttl = 3600
    priority = 0
  }

  record {
    name = join(".", compact(["nomad", var.subdomain]))
    type = "A"
    data = "${google_compute_global_address.global_ip.address}"
    ttl = 3600
    priority = 0
  }

  record {
    name = join(".", compact(["consul", var.subdomain]))
    type = "A"
    data = "${google_compute_global_address.global_ip.address}"
    ttl = 3600
    priority = 0
  }

  record {
    name = join(".", compact(["vault", var.subdomain]))
    type = "A"
    data = "${google_compute_global_address.global_ip.address}"
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
    path_matcher = "defaultpaths"
  }

  path_matcher {
    name            = "defaultpaths"
    default_service = google_compute_backend_service.services["fabiolb"].self_link
  }

  dynamic "host_rule" {
      for_each = local.domains
      content {
          hosts = ["${host_rule.value}"]
          path_matcher = "${contains(keys(local.services), split(".", host_rule.value)[0]) ? split(".", host_rule.value)[0] : "fabiolb"}"
      }
  }

  dynamic "path_matcher" {
      for_each = local.services
      content {
          name = path_matcher.key
          default_service = google_compute_backend_service.services[path_matcher.key].self_link
      }
  }
}

resource "google_compute_target_https_proxy" "default" {
  name             = "https-proxy"
  url_map          = google_compute_url_map.services.self_link
  ssl_certificates = google_compute_managed_ssl_certificate.client_cert.*.self_link
}

resource "google_compute_target_http_proxy" "http" {
  name        = "http-target-proxy"
  url_map     = google_compute_url_map.services.self_link
}

resource "google_compute_global_forwarding_rule" "default" {
  name       = "ssl-global-rule"
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
