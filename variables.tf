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

variable "ssh_username" {
    type = string
}

variable "network_name" {
    default = "default-network"
}

variable "firewall_name" {
    default = "default-firewall"
}