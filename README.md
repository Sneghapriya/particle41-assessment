# SIMPLE TIME SERVICE

This guide will walk you through the process of provisioning infrastructure using Terraform and deploying the **Simple time service** application to GKE using GitHub Actions

## Project Structure
```
├── .github/
│   └── workflows/
│       ├── deploy.yaml      # Workflow for provisioning and deploying 
├── kubernets_manifests/     
│   ├── deployment.yaml      # Deploy the application    
│   ├── service.yaml         # Expose the service          
├── terraform/
│   ├── main.tf              # Defining resources to be created             
│   ├── provider.tf          # Provider configurations and backend   
│   ├── terraform.tfvars     # Define the variable values  
│   └── variables.tf         # Define the variables       
├── app/
│   ├── main.py              # Simple time serice application           
│   ├── requirements.txt     # Required dependencies      
│   ├── Dockerfile           # Steps to build docker image
└── README.md 
```

## Prerequisites
Before you begin, ensure you have the following:

* Google Cloud Account: Google Cloud account with billing enabled and a project created
* gcloud CLI: Enable the Google Cloud SDK command-line tool. 
* GitHub Account: GitHub account to host your repository and use GitHub Actions.
* Terraform:(Optional) Install Terraform: https://www.terraform.io/downloads
* kubectl:(Optional) The Kubernetes command-line tool. Install it: https://kubernetes.io/docs/tasks/tools/install-kubectl/
* Docker:(Optional) Install Docker Desktop or Docker Engine: https://docs.docker.com/get-docker/

The **optional** may not be required if you're running everything via GitHub Actions, as the GitHub runner will handle these tasks for you.

## 1. Enabling the API

Run the following command in cloud shell to enable the required Google Cloud APIs:
```
gcloud services enable \
  container.googleapis.com \
  compute.googleapis.com \
  storage.googleapis.com \
  artifactregistry.googleapis.com
  ```
## 2.  Create a Service Account and Download JSON Credentials
**Create service account**
```
gcloud iam service-accounts create gke-deploy-sa \
  --description="Service Account with Project Editor role" \
  --display-name="GKE Deploy SA with Project Editor Role"

gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
  --member="serviceAccount:gke-deploy-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/editor"
```
Replace ` YOUR_PROJECT_ID ` with your id of the project

**Download the json key**
```
gcloud iam service-accounts keys create gke-deploy-sa-key.json \
  --iam-account gke-deploy-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com
```
This will create the json key file in the existing directory so we can download it. Store the file carefully.

## 3. Store Credentials and Project ID in GitHub Secrets
* Navigate to your GitHub repository.
* Go to `Settings` > `Secrets` > `New repository secret`.
* Create two secrets:
   * **GCP_GKE_SECRET**: Upload the gke-deploy-sa-key.json file you just downloaded.
   * **PROJECT_ID**: Add your Google Cloud project ID.

These secrets will be used in your GitHub Actions workflow for authentication.

## 4. Create Artifact Registry
Create an Artifact Registry repository where you can store your Docker images. This is necessary for deploying the application.
```
# Create an Artifact Registry repository
gcloud artifacts repositories create artifact \
  --repository-format=docker \
  --location=us-central1
```
This repository will be used in github actions while pushing the docker image.
## 5. Change the code accordingly

* Clone the repository to your local to make the changes
* In `terraform/terraform.tfvars` edit the values based on your requirements.
* Commit the changes and push to the main branch.

## 6. Github Action for deployment

This GitHub Actions workflow automates the process of:

* **Provisioning Infrastructure**: It uses Terraform to create necessary resources like a Google Kubernetes Engine (GKE) cluster and networking components.
* **Building and Deploying the Application**: It then builds a Docker image, pushes it to Google Artifact Registry, and deploys the application to the GKE cluster using kubectl.

In simple terms, this file automates setting up the infrastructure and deploying your application to GKE every time you push code to the main branch.  



