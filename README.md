# terraform-gcp-hashi-cluster
A terraform module to setup hashicorp clients and servers on google cloud (Consul & Nomad)

# How to use (Terraform)

variables: 
    environment = The environment you're deploying to (Ex: Dev, Prod, etc)
    project = The name of the GCP project
    domains = The domains used to access the machines (Must be Godaddy)
    account_email = The service account email (Ex: account@projectname.iam.gserviceaccount.com)
    machine_image = The path to the base machine image (Ex: projects/project_name/global/images/hashi-client-2019-09-29) 

# How to use (Packer)

Coming Soon