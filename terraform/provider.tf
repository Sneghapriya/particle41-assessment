// Configure the terraform google provider
provider "google" {
  credentials = file("gcp_credentials.json")
  project     = "var.project"
  region      = "us-central1"
}

