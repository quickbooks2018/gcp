# GCP

- login with cli
```bash
gcloud auth login
gcloud auth login --no-launch-browser
```

- login with serviceaccount
```bash
gcloud auth activate-service-account --key-file=key.json
```

- kasm-user
```bash
sudo chown -R kasm-user:kasm-user /home/kasm-user/.config/gcloud
chmod -R 700 /home/kasm-user/.config/gcloud
```

- Gcloud CLI Set default project
```bash
gcloud config set project playground-s-11-25d5584b
```

- GKE create cluster with 3 nodes gcloud cli
```bash
# enable kubernetes api services
gcloud services enable container.googleapis.com

# create cluster
gcloud container clusters create cloudgeeks --num-nodes=3 --zone=us-central1-a --release-channel=stable

# get credentials
gcloud container clusters get-credentials cloudgeeks --zone us-central1-a

# enable logging and monitoring
gcloud container clusters update cloudgeeks --zone us-central1-a --logging=SYSTEM,WORKLOAD --monitoring=SYSTEM

# resize cluster
gcloud container clusters resize cloudgeeks --zone us-central1-a --size=2

# enable autoscaling
gcloud container clusters update cloudgeeks --zone us-central1-a --enable-autoscaling --min-nodes=1 --max-nodes=5

# delete cluster
gcloud container clusters delete cloudgeeks --zone us-central1-a
```
