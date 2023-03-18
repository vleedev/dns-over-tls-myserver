provider "google" {
  # The google name must be defined first in terraform required_providers
  # We are using terraform cloud
  # Google credentials is set in terraform workspace variable ENV GOOGLE_CREDENTIALS
  project = var.google_project
  region  = var.google_region
  zone    = var.google_zone
}
