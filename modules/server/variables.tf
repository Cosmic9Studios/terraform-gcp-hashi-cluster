// Mandatory Variables

# Example: account@projectname.iam.gserviceaccount.com
variable "account_email" {
  type = string
}

variable "name" {
  type = string
}

variable "network_name" {
  type = string
}

variable "project" {
  type = string
}

# Example: projects/project_name/global/images/hashi-client-2019-09-29
variable "machine_image" {
  type = string
}

// Optional Variables

variable "num_instances" {
  default = 1
}

variable "zone" {
  default = "us-central1-a"
}

variable "desc" {
  default = "Create with Terraform"
}

variable "machine_type" {
  default = "g1-small"
}

variable "startup_script_path" {
  default = "./files/startup.sh"
}

variable "labels" {
  default = {}
}

variable "tags" {
  default = ["allow-icmp", "consul-join"]
}

# Best Practice: https://cloud.google.com/compute/docs/access/service-accounts?hl=en_US#accesscopesiam
variable "account_scopes" {
  default = ["cloud-platform"]
}
