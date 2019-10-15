# Mandatory Variables

variable "environment" { 
    type = string
}

variable "project" {
    type = string
}

variable "domains" {
    type = list(string)
}

# Example: account@projectname.iam.gserviceaccount.com
variable "account_email" {
    type = string
}

variable "account_json_path" {
    type = string
}

variable "ssh_username" {
    type = string
}

# Optional Global Variables

variable "nomad_address" {
    default = ""
}

variable "network_name" {
    default = "default-network"
}

variable "firewall_name" {
    default = "default-firewall"
}

variable "zone" {
    default = "us-central1-a"
}

variable "tags" {
    default = ["allow-icmp", "consul-join"]
}

# Best Practice: https://cloud.google.com/compute/docs/access/service-accounts?hl=en_US#accesscopesiam
variable "account_scopes" {
    default = ["cloud-platform"]
}

variable "network_tier" {
    default = "STANDARD"
}

# Optional Client Variables 

variable "client_target_size" { 
    default = 1
}

variable "client_machine_type" {
    default = "g1-small"
}

# Optional Server Variables

variable "server_target_size" {
    default = 1
}

variable "server_machine_type" {
    default = "g1-small"
}