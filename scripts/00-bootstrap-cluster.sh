#!/bin/bash
set -e

echo "=========================================="
echo "CKA Simulator - Cluster Bootstrap"
echo "=========================================="

CONTROL_PLANE_IP=$(hostname -I | awk '{print $1}')
POD_CIDR="192.168.0.0/16"

echo "Control Plane IP: ${CONTROL_PLANE_IP}"
echo "Pod Network CIDR: ${POD_CIDR}"

echo "Initializing Kubernetes control plane..."
kubeadm init \
  --pod-network-cidr=${POD_CIDR} \
  --apiserver-advertise-address=${CONTROL_PLANE_IP} \
  --kubernetes-version=v1.31.0 \
  --upload-certs

mkdir -p /home/ubuntu/.kube
cp -i /etc/kubernetes/admin.conf /home/ubuntu/.kube/config
chown ubuntu:ubuntu /home/ubuntu/.kube/config

mkdir -p /root/.kube
cp -i /etc/kubernetes/admin.conf /root/.kube/config

echo ""
echo "=========================================="
echo "Control Plane Initialized!"
echo "=========================================="

echo "Installing Calico CNI..."
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.2/manifests/calico.yaml

echo "Waiting for Calico pods to be ready..."
kubectl wait --for=condition=ready pod -l k8s-app=calico-node -n kube-system --timeout=300s || true
kubectl wait --for=condition=ready pod -l k8s-app=calico-kube-controllers -n kube-system --timeout=300s || true

echo "Calico CNI installed successfully!"

KUBEADM_JOIN_CMD=$(kubeadm token create --print-join-command)
echo "${KUBEADM_JOIN_CMD}" > /home/ubuntu/kubeadm-join-command.sh
chmod +x /home/ubuntu/kubeadm-join-command.sh
chown ubuntu:ubuntu /home/ubuntu/kubeadm-join-command.sh

echo ""
echo "=========================================="
echo "NEXT STEPS"
echo "=========================================="
echo "1. Copy and run this join command on EACH worker node:"
echo ""
cat /home/ubuntu/kubeadm-join-command.sh
echo ""
echo "2. After all workers have joined, run:"
echo "   sudo /home/ubuntu/01-install-addons.sh"
echo "=========================================="
