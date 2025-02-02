// Configure the terraform google provider
provider "google" {
  credentials = file("gcp_credentials.json")
  project     = "lumen-b-ctl-047"
  region      = "us-central1"
}

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.2.0"
    }
  }
  backend "gcs" {
    bucket = "terraform-state"
    prefix = "particle41/state" // Optional: Adjust the prefix as needed
    credentials = "gcp_credentials.json"
  }
}