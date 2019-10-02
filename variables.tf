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

# Example: projects/project_name/global/images/hashi-client-2019-09-29
variable "machine_image" {
  type = string
}