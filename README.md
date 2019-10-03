# terraform-gcp-hashi-cluster
A terraform module to setup hashicorp clients and servers on google cloud (Consul & Nomad)

# MUST HAVES
    * GCP Account 
    * Godaddy Account (This may change in the future if requested)

# How to use (Terraform)

variables: 
    environment = The environment you're deploying to (Ex: Dev, Prod, etc)
    project = The name of the GCP project
    domains = The domains used to access the machines (Must be Godaddy)
    account_email = The service account email (Ex: account@projectname.iam.gserviceaccount.com)
    ssh_username = The username used to ssh into the machine

# How to use (Packer)

Use the terraform module to automatically run packer script