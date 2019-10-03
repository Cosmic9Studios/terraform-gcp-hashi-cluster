provider "google" {
  project = var.project
  zone    = var.zone
}

provider "google-beta" {
  project = var.project 
  zone    = var.zone
}

resource "google_compute_instance_template" "default" {
  name_prefix = var.name
  description = var.desc

  disk {
    source_image = "projects/${var.project}/global/images/${var.machine_image}"
    auto_delete  = true
    boot         = true
  }

  tags         = var.tags
  labels       = var.labels
  machine_type = var.machine_type

  network_interface {
    network = var.network_name
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

resource "google_compute_instance_group_manager" "default" {
  provider           = "google-beta"
  base_instance_name = var.name
  name               = "${var.name}-group-manager"
  target_size        = var.num_instances

  update_policy{
    type = "PROACTIVE"
    minimal_action = "REPLACE"
    min_ready_sec = 120
    max_unavailable_fixed = 1
    max_surge_fixed = 1
  }

  version {
    name              = "default"
    instance_template = google_compute_instance_template.default.self_link
  }

  lifecycle {
    create_before_destroy = true
  }
}
