# terraform-gcp-hashi-cluster
An opinionated terraform module to setup hashicorp clients and servers on google cloud (Consul, Nomad, and Vault)

# MUST HAVES
    * GCP Account 
    * Godaddy Account (This may change in the future if requested)

*PLEASE NOTE: Packer runs as a data source meaning that the first time you run this module it's going to take a while with no output. DO NOT stop the process, just let it run.
After the packer images are created terraform will continue to run.*

# How to use

**variables:**
    environment = The environment you're deploying to (Ex: Dev, Prod, etc)
    project = The name of the GCP project
    domains = The domains used to access the machines (Must be Godaddy)
    account_email = The service account email (Ex: account@projectname.iam.gserviceaccount.com)
    ssh_username = The username used to ssh onto the machine (Ex: c9s)
    account_json_path = The path to your service account's json file


# Sample Terragrunt implementation

./gcp/hashi-cluster/terragrunt.hcl

```hcl
remote_state {
  backend = "gcs"
  config = {
    bucket = "state"
    prefix = "prod/gcp/hashi-cluster"
  } 
}

terraform {
  source = "git::https://github.com/Cosmic9Studios/terraform-gcp-hashi-cluster.git//module?ref=v2.0.0"
}

inputs = {
  environment   = "prod",
  project       = "project_name",
  domains       = ["domain.com"]
  account_email = "service@project_name.iam.gserviceaccount.com"
  ssh_username  = "c9s"
  account_json_path = "${get_env("GOOGLE_APPLICATION_CREDENTIALS", "")}"
}
```

./gcp/hashi-server/hashi-cluster/backend.tf

```hcl
terraform {
    backend "gcs" {}
}
```