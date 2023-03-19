resource "google_compute_network" "project-network" {
  # Struct: type - resource local name
  # Type: required, check https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network
  # Resource local name: it must be unique in the terraform tool
  # Terraform will look up the type in terraform module
  name = "${var.project.name}-network"
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
  }
}
