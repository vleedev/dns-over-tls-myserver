resource "google_compute_network" "project-network" {
  # Struct: type - resource local name
  # Type: required, check https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network
  # Resource local name: it must be unique in the terraform tool
  # Terraform will look up the type in terraform module
  name = "${var.project.name}-network"
}
# Reverse a static IP address
# NAT it to google compute instance in block network_interface > access_config > nat_ip
resource "google_compute_address" "myserver_ip" {
  name   = "${var.project.name}-ipv4-address"
  region = "us-west1"
}
# Declare DNS container
module "dns-container" {
  source           = "terraform-google-modules/container-vm/google"
  version          = "3.1.0"
  cos_image_family = "101-lts"
  # Run DNS container https://github.com/qdm12/dns
  container = {
    image = "qmcgaw/dns"
  }
  restart_policy = "Always"
}

resource "google_compute_instance" "myserver" {
  name         = "${var.project.name}-server"
  machine_type = "e2-micro"
  zone         = "us-west1-c"
  boot_disk {
    auto_delete = true
    initialize_params {
      # Use DNS container in google compute instance
      image = module.dns-container.source_image
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
  # metadata = {
  #   "ssh-keys" = <<EOT
  #   EOT
  # }
}
# Create firewall rules
resource "google_compute_firewall" "icmp" {
  name          = "${var.project.name}-allow-icmp"
  network       = google_compute_network.project-network.id
  source_ranges = ["0.0.0.0/0"]
  # Priority can be 0 - 65535
  # Default is 1000
  # Set to 65535, this rule will be disable
  priority = 65534

  allow {
    protocol = "icmp"
  }
}
# Allow SSH connection from all
resource "google_compute_firewall" "ssh" {
  name = "${var.project.name}-allow-ssh"
  allow {
    ports    = ["22"]
    protocol = "tcp"
  }
  direction = "INGRESS"
  network   = google_compute_network.project-network.id
  # Priority can be 0 - 65535
  # Default is 1000
  # Set to 65535, this rule will be disable
  priority      = 65534
  source_ranges = ["0.0.0.0/0"]
  # If you want to apply to a specific instance
  # target_tags   = ["ssh"]
}
