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
