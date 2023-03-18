provider "google" {
  # The google name must be defined first in terraform required_providers
  # We are using terraform cloud
  # Google credentials is set in terraform workspace variable ENV GOOGLE_CREDENTIALS
  project = "default-259811"
  region  = "us-west1"
  zone    = "us-west1-c"
}
