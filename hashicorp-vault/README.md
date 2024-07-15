# Hashicoport Vault Setup on GKE

- Run Bash Script these will certs in kubernetes secret vault namespace
```bash
k create ns vault

cd tls
chmod +x tls.sh
./tls.sh 
```

- GCP KMS kms.sh
```bash
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
```

- Install Hashicorp Vault with Helm
```bash
helm repo ls
helm repo add hashicorp https://helm.releases.hashicorp.com
helm search repo hashicorp
helm search repo hashicorp/vault --versions
helm show values hashicorp/vault --version 0.28.0
# helm show values hashicorp/vault --version 0.28.0 > vault-values.yaml
helm repo update

helm -n vault upgrade --install vault hashicorp/vault --version 0.28.0 --values gke-values.yaml --create-namespace --wait
```