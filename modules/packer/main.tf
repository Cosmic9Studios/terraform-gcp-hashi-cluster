locals {
    file_hash = filemd5("${path.module}/packer.json")
}

resource "null_resource" "packer_build" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    packer_file = local.file_hash
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