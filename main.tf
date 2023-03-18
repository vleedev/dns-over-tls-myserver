terraform {
  cloud {
    # This configuration to let terraform know we are using terraform cloud
    organization = "vleedev"
    workspaces {
      name = "dns-over-tls-myserver"
    }
  }
  required_providers {
    # config alias name
    # Use this alias name in other configuration files
    google = {
      # The important one is source and version
      # We have to check the registry doc to config
      # https://registry.terraform.io/providers/hashicorp/google/latest
      # Terraform will check the registry when initializing via command: terraform init
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }
}
