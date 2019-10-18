resource "google_compute_instance_template" "server" {
  name_prefix = "hashi-server"
  description = "Created with Terraform"

  disk {
    source_image = "${var.project}/${data.external.run_packer.result["server"]}"
    auto_delete  = true
    boot         = true
  }

  tags         = var.tags
  machine_type = var.client_machine_type

  network_interface {
    network = google_compute_network.default.name
  }

  service_account {
    email  = var.account_email
    scopes = var.account_scopes
  }

  lifecycle {
    create_before_destroy = true
  }

  metadata_startup_script = <<EOT
    sudo pm2 start /scripts/nomad.sh -- -bootstrap-expect=${var.server_target_size}
    sudo pm2 start /scripts/consul.sh -- "-bootstrap-expect ${var.server_target_size}"
  EOT
}

resource "google_compute_instance_group_manager" "server" {
  provider           = "google-beta"
  base_instance_name = "hashi-server"
  name               = "hashi-server-group-manager"
  target_size        = var.server_target_size

  update_policy{
    type = "PROACTIVE"
    minimal_action = "REPLACE"
    min_ready_sec = 120
    max_unavailable_fixed = 1
    max_surge_fixed = 1
  }

  version {
    name              = "default"
    instance_template = google_compute_instance_template.server.self_link
  }

  lifecycle {
    create_before_destroy = true
  }
}
