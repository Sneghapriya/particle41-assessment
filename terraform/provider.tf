// Configure the terraform google provider
provider "google" {
  credentials = file("gcp_credentials.json")
  project     = var.project
  region      = "us-central1"
}

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.2.0"
    }
  }

}