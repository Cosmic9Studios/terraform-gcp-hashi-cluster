module "nomad" {
    source = "git::https://github.com/Cosmic9Studios/terraform-nomad-job.git?ref=v2.0.0"
    address = coalesce(var.nomad_address, "http://${join(".", compact(["nomad", var.subdomain, var.domains[0]]))}")
    data = [
        {
            file_path = "${path.module}/nomad/fabio.nomad"
            vars = {}
        },
        {
            file_path = "${path.module}/nomad/vault.nomad"
            vars = {
                project = var.project
                vault_bucket = var.vault_bucket_name
                NOMAD_IP_lb = "$${NOMAD_IP_lb}"
            }
        }
    ]

    nomad_depends_on = [google_compute_instance_group_manager.client, google_compute_managed_ssl_certificate.client_cert]
}