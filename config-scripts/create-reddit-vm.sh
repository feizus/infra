#! /bin/bash
gcloud compute instances create reddit-app-1\
  --image-family reddit-full \
  --machine-type=g1-small \
  --zone=us-central1-a \
  --tags puma-server \
  --restart-on-failure
