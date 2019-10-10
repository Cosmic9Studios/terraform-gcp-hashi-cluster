data "archive_file" "init" {
  type        = "zip"
  source_dir = "./packer"
  output_path = "data.zip"
}

resource "null_resource" "packer_build" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    src_hash = data.archive_file.init.output_sha
  }

  provisioner "local-exec" {
    working_dir = path.module
    command = <<EOF
        cd ${path.module}/packer
        packer build -force -var 'project=${var.project}' -var 'image_suffix=${data.archive_file.init.output_md5}' -var 'ssh_username=${var.ssh_username}' -var 'account_json_path=${var.account_json_path}' packer.json
    EOF
  }
}