#!/bin/bash

# Enable the Ingress controller in Minikube
minikube addons enable ingress

# Wait for the ingress controller to be ready
echo "Waiting for Ingress controller to be ready..."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s

echo "Ingress controller is ready!"
