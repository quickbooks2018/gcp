# Hashicoport Vault Setup on GKE

- Run Bash Script these will certs in kubernetes secret vault namespace
```bash
k create ns vault
chmod +x cloudflare-tls.sh
./cloudflare-tls.sh

kubectl create secret generic vault-tls \
  --namespace vault \
  --from-file=vault.ca=/mnt/tls/ca.pem \
  --from-file=vault.crt=/mnt/tls/vault.pem \
  --from-file=vault.key=/mnt/tls/vault-key.pem

Optional:
cd tls
chmod +x tls.sh
./tls.sh
```

- Run KMS kms/kms.sh

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
