terraform {
 backend "gcs" {
    bucket = "terraform-state"
    prefix = "particle41/state" // Optional: Adjust the prefix as needed
    credentials = "gcp_credentials.json"
  }
}