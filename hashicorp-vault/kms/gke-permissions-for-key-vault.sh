#!/bin/bash

# Set your variables here
PROJECT_ID="playground-s-11-8b0011ac"
CLUSTER_NAME="cluster-1"
CLUSTER_ZONE="us-central1-c"
K8S_NAMESPACE="vault"
K8S_SERVICE_ACCOUNT="vault"
GCP_SERVICE_ACCOUNT="cli-service-account-1@playground-s-11-8b0011ac.iam.gserviceaccount.com"
KMS_KEY_RING="vault-key-ring"
KMS_CRYPTO_KEY="vault-key"
KMS_LOCATION="us-central1"  # or your specific region

# Enable necessary APIs
gcloud services enable container.googleapis.com --project=$PROJECT_ID
gcloud services enable cloudkms.googleapis.com --project=$PROJECT_ID

# Create the GCP service account if it doesn't exist
gcloud iam service-accounts create cli-service-account-1 \
    --project=$PROJECT_ID \
    --display-name="Vault KMS Service Account" \
    || echo "Service account already exists"

# Grant Cloud KMS permissions to the service account
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$GCP_SERVICE_ACCOUNT" \
    --role="roles/cloudkms.cryptoKeyEncrypterDecrypter"

# Create key ring and crypto key if they don't exist
gcloud kms keyrings create $KMS_KEY_RING \
    --project=$PROJECT_ID \
    --location=$KMS_LOCATION \
    || echo "Key ring already exists"

gcloud kms keys create $KMS_CRYPTO_KEY \
    --project=$PROJECT_ID \
    --location=$KMS_LOCATION \
    --keyring=$KMS_KEY_RING \
    --purpose=encryption \
    || echo "Crypto key already exists"

# Set up Workload Identity
gcloud container clusters update $CLUSTER_NAME \
    --project=$PROJECT_ID \
    --zone=$CLUSTER_ZONE \
    --workload-pool=$PROJECT_ID.svc.id.goog

# Create Kubernetes namespace if it doesn't exist
kubectl create namespace $K8S_NAMESPACE || echo "Namespace already exists"

# Create Kubernetes service account if it doesn't exist
kubectl create serviceaccount $K8S_SERVICE_ACCOUNT --namespace $K8S_NAMESPACE \
    || echo "Service account already exists"

# Add IAM policy binding for Workload Identity
gcloud iam service-accounts add-iam-policy-binding $GCP_SERVICE_ACCOUNT \
    --project=$PROJECT_ID \
    --role="roles/iam.workloadIdentityUser" \
    --member="serviceAccount:$PROJECT_ID.svc.id.goog[$K8S_NAMESPACE/$K8S_SERVICE_ACCOUNT]"

# Annotate Kubernetes service account
kubectl annotate serviceaccount $K8S_SERVICE_ACCOUNT \
    --namespace $K8S_NAMESPACE \
    iam.gke.io/gcp-service-account=$GCP_SERVICE_ACCOUNT

echo "Setup complete. Please update your Vault configuration to use the following:"
echo "GCP Project ID: $PROJECT_ID"
echo "KMS Key Ring: $KMS_KEY_RING"
echo "KMS Crypto Key: $KMS_CRYPTO_KEY"
echo "KMS Location: $KMS_LOCATION"
echo "Kubernetes Namespace: $K8S_NAMESPACE"
echo "Kubernetes Service Account: $K8S_SERVICE_ACCOUNT"