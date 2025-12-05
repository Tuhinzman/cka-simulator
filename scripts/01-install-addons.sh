#!/bin/bash
set -e

echo "=========================================="
echo "CKA Simulator - Installing Addons"
echo "=========================================="

echo "Waiting for all nodes to be ready..."
kubectl wait --for=condition=ready node --all --timeout=300s

echo ""
echo "Installing Metrics Server..."
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.7.1/components.yaml

kubectl patch deployment metrics-server -n kube-system --type='json' -p='[
  {
    "op": "add",
    "path": "/spec/template/spec/containers/0/args/-",
    "value": "--kubelet-insecure-tls"
  }
]'

echo "Waiting for Metrics Server to be ready..."
kubectl wait --for=condition=ready pod -l k8s-app=metrics-server -n kube-system --timeout=300s || true
echo "Metrics Server installed successfully!"

echo ""
echo "Installing NGINX Ingress Controller..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.11.1/deploy/static/provider/cloud/deploy.yaml

echo "Waiting for NGINX Ingress Controller to be ready..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/component=controller -n ingress-nginx --timeout=300s || true
echo "NGINX Ingress Controller installed successfully!"

echo ""
echo "Installing Gateway API CRDs..."
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.1.0/standard-install.yaml
echo "Gateway API CRDs installed successfully!"

echo ""
echo "Installing cert-manager..."
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.15.0/cert-manager.yaml

echo "Waiting for cert-manager to be ready..."
kubectl wait --for=condition=ready pod -l app=cert-manager -n cert-manager --timeout=300s || true
kubectl wait --for=condition=ready pod -l app=cainjector -n cert-manager --timeout=300s || true
kubectl wait --for=condition=ready pod -l app=webhook -n cert-manager --timeout=300s || true
echo "cert-manager installed successfully!"

echo ""
echo "Installing Local Path Provisioner..."
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.28/deploy/local-path-storage.yaml

kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

echo "Local Path Provisioner installed successfully!"

echo ""
echo "Adding Argo CD Helm repository..."
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
echo "Helm repository added successfully!"

echo ""
echo "=========================================="
echo "All Addons Installed Successfully!"
echo "=========================================="
echo ""
kubectl get nodes
echo ""
kubectl get pods -A
echo ""
echo "Next: Run sudo /home/ubuntu/02-setup-all-questions.sh"
echo "=========================================="
