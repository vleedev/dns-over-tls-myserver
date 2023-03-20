# This empty variable will be overrided by terraform cloud variable
variable "google_project" {}
# Variable with object type
variable "project" {
  type = object({
    name = string
  })
  default = {
    name = "dns-over-tls"
  }
}
