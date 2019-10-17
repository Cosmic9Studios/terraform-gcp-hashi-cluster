

data "archive_file" "init" {
  type        = "zip"
  source_dir = "${path.module}/packer/salt/"
  output_path = "/tmp/packer_salt.zip"
}

locals {
    image_suffix = md5(join("", [
        data.archive_file.init.output_md5, 
        filemd5("${path.module}/packer/packer.json"),
        filemd5("${path.module}/packer.tf")
    ]))
}

data "external" "run_packer" {
    working_dir = "${path.module}/packer"
    program = ["pwsh", "./packer.ps1",
        "${var.project}",
        "${local.image_suffix}",
        "${var.ssh_username}",
        "${var.account_json_path}"
    ]
}

output "image_suffix" {
    value = local.image_suffix
}

output "full_output" {
    value = data.external.run_packer.result["output"]
}