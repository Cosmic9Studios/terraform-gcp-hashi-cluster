locals {
    file_hash = filemd5("${path.module}/packer.json")
}

data "archive_file" "init" {
  type        = "zip"
  source_dir = "./"
  output_path = "data.zip"
}

resource "null_resource" "packer_build" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    src_hash = data.archive_file.init.output_sha
  }

  provisioner "local-exec" {
    working_dir = path.module
    command = "packer build -force -var 'project=${var.project}' -var 'image_suffix=${local.file_hash}' -var 'ssh_username=${var.ssh_username}' -var 'account_json_path=${var.account_json_path}' packer.json"
  }
}

output "server_image" {
  value = "hashi-server-${local.file_hash}"
}

output "client_image" {
  value = "hashi-client-${local.file_hash}"
}