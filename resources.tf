resource "google_compute_network" "dns-over-tls-network" {
  # Struct: type - resource local name
  # Type: required, check https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network
  # Resource local name: it must be unique in the terraform tool
  # Terraform will look up the type in terraform module
  name = "dns-over-tls-network"
}