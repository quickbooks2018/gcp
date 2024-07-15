#!/bin/bash
set -e

# Set up Google Cloud KMS
gcloud services enable cloudkms.googleapis.com

# Set variables
PROJECT_ID=$(gcloud config get-value project)
LOCATION="us-central1"  # Changed from "global" to a specific region
KEYRING_NAME="vault-key-ring"
KEY_NAME="vault-key"

# Set the project
gcloud config set project $PROJECT_ID

# Create keyring and key
gcloud kms keyrings create $KEYRING_NAME --location $LOCATION
gcloud kms keys create $KEY_NAME --location $LOCATION --keyring $KEYRING_NAME --purpose encryption

# Get the default compute service account
GKE_SA=$(gcloud iam service-accounts list --filter="name:compute@developer.gserviceaccount.com" --format="value(email)")

# Grant permissions
gcloud kms keys add-iam-policy-binding $KEY_NAME \
    --location $LOCATION \
    --keyring $KEYRING_NAME \
    --member serviceAccount:$GKE_SA \
    --role roles/cloudkms.cryptoKeyEncrypterDecrypter

# Create Vault Configuration file gcp-kms-config.hcl
cat <<EOF > gcp-kms-config.hcl
seal "gcpckms" {
  project     = "$PROJECT_ID"
  region      = "$LOCATION"
  key_ring    = "$KEYRING_NAME"
  crypto_key  = "$KEY_NAME"
}
EOF

# Ensure the vault namespace exists
kubectl create namespace vault --dry-run=client -o yaml | kubectl apply -f -

# Create a Kubernetes secret with this configuration
kubectl -n vault create secret generic gcp-kms-config --from-file=config.hcl=gcp-kms-config.hcl

echo "Setup completed successfully."