resource "google_compute_network" "project-network" {
  # Struct: type - resource local name
  # Type: required, check https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network
  # Resource local name: it must be unique in the terraform tool
  # Terraform will look up the type in terraform module
  name = "${var.project.name}-network"
}
module "vpc_firewall_rules" {
  source       = "terraform-google-modules/network/google//modules/firewall-rules"
  project_id   = var.google_project
  network_name = google_compute_network.project-network.name

  rules = [
    # Allow SSH connection from everywhere
    {
      name        = "vpc-allow-ssh-ingress"
      description = null
      direction   = "INGRESS"
      # Priority can be 0 - 65535
      # Default is 1000
      # Set to 65535, this rule will be disable
      priority                = 65534
      ranges                  = ["0.0.0.0/0"]
      source_tags             = null
      source_service_accounts = null
      target_tags             = null
      target_service_accounts = null
      allow = [{
        protocol = "tcp"
        ports    = ["22"]
      }]
      deny       = []
      log_config = null
      # log_config = {
      # metadata = "INCLUDE_ALL_METADATA"
      # }
    },
    {
      name        = "vpc-allow-icmp"
      description = null
      direction   = "INGRESS"
      # Priority can be 0 - 65535
      # Default is 1000
      # Set to 65535, this rule will be disable
      priority                = 65534
      ranges                  = ["0.0.0.0/0"]
      source_tags             = null
      source_service_accounts = null
      target_tags             = null
      target_service_accounts = null
      allow = [{
        protocol = "icmp"
        ports    = null
      }]
      deny       = []
      log_config = null
      # log_config = {
      # metadata = "INCLUDE_ALL_METADATA"
      # }
    },
    {
      name        = "vpc-allow-dns53"
      description = null
      direction   = "INGRESS"
      # Priority can be 0 - 65535
      # Default is 1000
      # Set to 65535, this rule will be disable
      priority                = 65534
      ranges                  = ["0.0.0.0/0"]
      source_tags             = null
      source_service_accounts = null
      target_tags             = null
      target_service_accounts = null
      allow = [{
        protocol = "udp"
        ports    = ["53"]
      }]
      deny       = []
      log_config = null
      # log_config = {
      # metadata = "INCLUDE_ALL_METADATA"
      # }
    },
    {
      name        = "vpc-allow-dns853-tcp"
      description = null
      direction   = "INGRESS"
      # Priority can be 0 - 65535
      # Default is 1000
      # Set to 65535, this rule will be disable
      priority                = 65534
      ranges                  = ["0.0.0.0/0"]
      source_tags             = null
      source_service_accounts = null
      target_tags             = null
      target_service_accounts = null
      allow = [{
        protocol = "tcp"
        ports    = ["853"]
      }]
      deny       = []
      log_config = null
      # log_config = {
      # metadata = "INCLUDE_ALL_METADATA"
      # }
    }
  ]
}

# Reverse a static IP address
# NAT it to google compute instance in block network_interface > access_config > nat_ip
resource "google_compute_address" "myserver_ip" {
  name   = "${var.project.name}-ipv4-address"
  region = "us-west1"
}
# Declare DNS container
module "gce-container" {
  source           = "terraform-google-modules/container-vm/google"
  version          = "3.1.0"
  cos_image_family = "101-lts"
  # Run DNS container https://github.com/qdm12/dns
  container = {
    image = "qmcgaw/dns"
    # image = "ghcr.io/vleedev/debug-tools:main"
    # https://github.com/qdm12/dns#environment-variables
    env = [
      {
        name  = "BLOCK_ADS"
        value = "on"
      },
      {
        name  = "PROVIDERS"
        value = "cloudflare,google,libredns,quad9,quadrant"
      }
    ],
  }
  restart_policy = "Always"
}

resource "google_compute_instance" "myserver" {
  name         = "${var.project.name}-server"
  machine_type = "e2-micro"
  zone         = "us-west1-c"
  # If true, allows Terraform to stop the instance to update its properties.
  allow_stopping_for_update = true
  boot_disk {
    auto_delete = true
    initialize_params {
      # Use DNS container in google compute instance
      image = module.gce-container.source_image
      size  = "10" # The minimum is 10GB
      type  = "pd-standard"
    }
  }

  network_interface {
    network = google_compute_network.project-network.id
    access_config {
      nat_ip = google_compute_address.myserver_ip.address
    }
  }
  metadata = {
    gce-container-declaration = module.gce-container.metadata_value
    # "ssh-keys" = <<EOT
    # EOT

    startup-script = <<-EOF1
      #! /bin/bash
      set -euo pipefail

      export DEBIAN_FRONTEND=noninteractive
      systemctl stop systemd-resolved
      systemctl disable systemd-resolved
    EOF1
  }

  lifecycle {
    create_before_destroy = true
  }
}
