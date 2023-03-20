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
  name = "${var.project.name}-ipv4-address"
}
resource "google_compute_instance" "myserver" {
  name         = "${var.project.name}-server"
  machine_type = "e2-micro"

  boot_disk {
    auto_delete = true
    initialize_params {
      image = "centos-stream-8-v20230306"
      size  = "20" # The minimum is 20GB
      type  = "pd-standard"
    }
  }

  network_interface {
    network = google_compute_network.project-network.id
    access_config {
      nat_ip = google_compute_address.myserver_ip.address
    }
  }
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
