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

# create new nodepool
gcloud container node-pools create cloudgeeks-nodepool --cluster=cloudgeeks --zone=us-central1-a --num-nodes=1 --machine-type=n1-standard-2

# delete cluster
gcloud container clusters delete cloudgeeks --zone us-central1-a
```

- launch a VM with gcloud
```bash
# on-demand
gcloud compute instances create regular-vm-1 regular-vm-2 \
    --zone=us-central1-b \
    --image-project=ubuntu-os-cloud \
    --image-family=ubuntu-2204-lts \
    --tags=allow-ssh
# preemptible
gcloud compute instances create spot-vm-1 spot-vm-2 \
    --zone=us-central1-b \
    --image-project=ubuntu-os-cloud \
    --image-family=ubuntu-2204-lts \
    --tags=allow-ssh \
    --preemptible

# Enable ssh from gcloud console only
gcloud services enable iap.googleapis.com

gcloud compute firewall-rules create allow-ssh-from-iap \
    --allow tcp:22 \
    --target-tags=allow-ssh \
    --source-ranges=35.235.240.0/20 \
    --description="Allow SSH access to VMs from Cloud IAP" \
    --direction=INGRESS
```

- launch vm's in a custom vpc
```bash
# Create a custom VPC
gcloud compute networks create custom-vpc \
    --subnet-mode=custom

# Create a subnetwork within the custom VPC
gcloud compute networks subnets create custom-subnet \
    --network=custom-vpc \
    --range=10.0.0.0/24 \
    --region=us-central1

# Create a firewall rule to allow internal communication (optional)
gcloud compute firewall-rules create allow-internal \
    --network=custom-vpc \
    --allow tcp,udp,icmp \
    --source-ranges=10.0.0.0/24 \
    --target-tags=allow-ssh \
    --description="Allow internal communication within the VPC"

# Enable IAP
gcloud services enable iap.googleapis.com

# Create a firewall rule to allow SSH from IAP
gcloud compute firewall-rules create allow-ssh-from-iap \
    --network=custom-vpc \
    --allow tcp:22 \
    --source-ranges=35.235.240.0/20 \
    --target-tags=allow-ssh \
    --description="Allow SSH access to VMs from Cloud IAP" \
    --direction=INGRESS

# Create regular VMs in the custom VPC
gcloud compute instances create regular-vm-1 regular-vm-2 \
    --zone=us-central1-b \
    --image-project=ubuntu-os-cloud \
    --image-family=ubuntu-2204-lts \
    --network=custom-vpc \
    --subnet=custom-subnet \
    --tags=allow-ssh

# Create spot VMs in the custom VPC
gcloud compute instances create spot-vm-1 spot-vm-2 \
    --zone=us-central1-b \
    --image-project=ubuntu-os-cloud \
    --image-family=ubuntu-2204-lts \
    --network=custom-vpc \
    --subnet=custom-subnet \
    --tags=allow-ssh \
    --preemptible

# Enable ssh from gcloud console only
gcloud services enable iap.googleapis.com

gcloud compute firewall-rules create allow-ssh-from-iap \
    --allow tcp:22 \
    --target-tags=allow-ssh \
    --source-ranges=35.235.240.0/20 \
    --description="Allow SSH access to VMs from Cloud IAP" \
    --direction=INGRESS
```


