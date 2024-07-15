#!/bin/bash

# Set your variables here
PROJECT_ID="playground-s-11-20da9440"
CLUSTER_NAME="cluster-1"
CLUSTER_ZONE="us-central1-c"
K8S_NAMESPACE="vault"
K8S_SERVICE_ACCOUNT="vault"
GCP_SERVICE_ACCOUNT_NAME="hahsicorp-vault"
GCP_SERVICE_ACCOUNT="$GCP_SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com"
KMS_KEY_RING="vault-key-ring"
KMS_CRYPTO_KEY="vault-key"
KMS_LOCATION="us-central1"

# Enable necessary APIs
gcloud services enable container.googleapis.com cloudkms.googleapis.com cloudresourcemanager.googleapis.com --project=$PROJECT_ID

# Check if the GCP service account exists
if gcloud iam service-accounts describe $GCP_SERVICE_ACCOUNT --project=$PROJECT_ID &>/dev/null; then
    echo "Service account $GCP_SERVICE_ACCOUNT already exists"
else
    echo "Error: Service account $GCP_SERVICE_ACCOUNT does not exist. Please create it manually or grant necessary permissions to create it."
    exit 1
fi

# Grant Cloud KMS permissions to the service account (this may fail due to permissions)
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$GCP_SERVICE_ACCOUNT" \
    --role="roles/cloudkms.cryptoKeyEncrypterDecrypter" || echo "Warning: Failed to add IAM policy binding. Please add it manually."

# Set up Workload Identity (this seems to have worked in the previous run)
gcloud container clusters update $CLUSTER_NAME \
    --project=$PROJECT_ID \
    --zone=$CLUSTER_ZONE \
    --workload-pool=$PROJECT_ID.svc.id.goog

# Create Kubernetes namespace if it doesn't exist
kubectl create namespace $K8S_NAMESPACE || echo "Namespace $K8S_NAMESPACE already exists"

# Create Kubernetes service account if it doesn't exist
kubectl create serviceaccount $K8S_SERVICE_ACCOUNT --namespace $K8S_NAMESPACE || echo "Service account $K8S_SERVICE_ACCOUNT already exists"

# Add IAM policy binding for Workload Identity
gcloud iam service-accounts add-iam-policy-binding $GCP_SERVICE_ACCOUNT \
    --project=$PROJECT_ID \
    --role="roles/iam.workloadIdentityUser" \
    --member="serviceAccount:$PROJECT_ID.svc.id.goog[$K8S_NAMESPACE/$K8S_SERVICE_ACCOUNT]"

# Annotate Kubernetes service account (use --overwrite to update existing annotation)
kubectl annotate serviceaccount $K8S_SERVICE_ACCOUNT \
    --namespace $K8S_NAMESPACE \
    --overwrite \
    iam.gke.io/gcp-service-account=$GCP_SERVICE_ACCOUNT

echo "Setup complete. Please update your Vault configuration to use the following:"
echo "GCP Project ID: $PROJECT_ID"
echo "KMS Key Ring: $KMS_KEY_RING"
echo "KMS Crypto Key: $KMS_CRYPTO_KEY"
echo "KMS Location: $KMS_LOCATION"
echo "Kubernetes Namespace: $K8S_NAMESPACE"
echo "Kubernetes Service Account: $K8S_SERVICE_ACCOUNT"
echo "GCP Service Account: $GCP_SERVICE_ACCOUNT"