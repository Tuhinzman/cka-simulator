# Troubleshooting Guide

## 🔧 Common Issues and Solutions

### Issue 1: SSH Connection Timeout ⚠️ (Most Common)

**Problem:** `ssh: connect to host X.X.X.X port 22: Operation timed out`

**Cause:** Your public IP address changed since deployment.

**Solution:**
```bash
# Check your current IP
curl -4 ifconfig.me

# Navigate to terraform directory
cd ~/Desktop/cka-simulator/terraform

# Update terraform.tfvars with new IP
MY_IP=$(curl -4 -s ifconfig.me)
cat > terraform.tfvars <<TFVARS
my_ip        = "${MY_IP}/32"
aws_region   = "us-east-1"
cluster_name = "cka-simulator"
worker_count = 3
TFVARS

# Apply changes (takes ~10 seconds)
terraform apply -auto-approve

# Try SSH again
ssh -i cka-simulator-key.pem ubuntu@$(terraform output -raw control_plane_public_ip)
```

---

### Issue 2: Instances Stopped/Terminated

**Problem:** Can't connect to instances, AWS console shows "stopped" state

**Solution:**
```bash
cd ~/Desktop/cka-simulator/terraform

# Check instance status
aws ec2 describe-instances \
  --filters "Name=tag:Project,Values=CKA-Simulator" \
  --query 'Reservations[*].Instances[*].[InstanceId,State.Name,PublicIpAddress]' \
  --output table

# Start all instances
aws ec2 start-instances --instance-ids \
  $(terraform show -json | jq -r '.values.root_module.resources[] | select(.type=="aws_instance") | .values.id' | tr '\n' ' ')

# Wait for startup (2-3 minutes)
sleep 120

# Refresh Terraform to get new public IPs
terraform refresh

# Get new control plane IP
terraform output control_plane_public_ip

# Don't forget to update your IP if it changed (see Issue 1)
```

---

### Issue 3: Lost SSH Key

**Problem:** `cka-simulator-key.pem` file was deleted or lost

**Solution - Extract from Terraform state:**
```bash
cd ~/Desktop/cka-simulator/terraform

# Extract private key from state
terraform show -json | jq -r '.values.root_module.resources[] | select(.type=="tls_private_key") | .values.private_key_pem' > cka-simulator-key.pem

# Set correct permissions
chmod 600 cka-simulator-key.pem

# Test SSH
ssh -i cka-simulator-key.pem ubuntu@$(terraform output -raw control_plane_public_ip)
```

---

### Issue 4: Metrics Server Not Working

**Problem:** `kubectl top nodes` returns `error: Metrics API not available`

**Solution:**
```bash
# On control plane, check metrics-server pod
kubectl get pods -n kube-system | grep metrics-server

# Re-patch for AWS (kubelet insecure TLS)
kubectl patch deployment metrics-server -n kube-system --type='json' -p='[
  {
    "op": "add",
    "path": "/spec/template/spec/containers/0/args/-",
    "value": "--kubelet-insecure-tls"
  }
]'

# Wait for rollout
kubectl rollout status deployment metrics-server -n kube-system

# Test after 30 seconds
sleep 30
kubectl top nodes
```

---

### Issue 5: Worker Nodes Not Ready

**Problem:** `kubectl get nodes` shows workers in `NotReady` state

**Solution:**
```bash
# Check node status
kubectl get nodes
kubectl describe node <worker-node-name>

# Check Calico pods
kubectl get pods -n kube-system | grep calico

# SSH to problematic worker
ssh -i terraform/cka-simulator-key.pem ubuntu@<WORKER_IP>

# Check kubelet
sudo systemctl status kubelet
sudo journalctl -u kubelet -n 50

# Restart kubelet
sudo systemctl restart kubelet
exit

# Verify
kubectl get nodes
```

---

### Issue 6: High AWS Costs

**Problem:** Unexpected AWS charges

**Solution - Stop instances when not practicing:**
```bash
cd ~/Desktop/cka-simulator/terraform

# Stop all instances (saves ~70% of costs)
aws ec2 stop-instances --instance-ids \
  $(terraform show -json | jq -r '.values.root_module.resources[] | select(.type=="aws_instance") | .values.id' | tr '\n' ' ')
```

**Solution - Complete cleanup:**
```bash
cd ~/Desktop/cka-simulator/terraform
terraform destroy -auto-approve
```

**Prevention - Set up AWS Budget:**
1. Go to: https://console.aws.amazon.com/billing/home#/budgets
2. Create budget: $10/month
3. Set alerts at 80% and 100%

---

### Issue 7: "No configuration files" Error

**Problem:** `Error: No configuration files` when running terraform

**Cause:** Wrong directory

**Solution:**
```bash
# Navigate to correct directory
cd ~/Desktop/cka-simulator/terraform

# Verify you're in the right place
ls -la
# Should see: main.tf, variables.tf, vpc.tf, etc.

# If .terraform doesn't exist, initialize
terraform init
```

---

### Issue 8: Pods Stuck in Pending

**Problem:** Pods remain in `Pending` state

**Diagnosis:**
```bash
# Describe pod to see events
kubectl describe pod <pod-name> -n <namespace>

# Check node resources
kubectl describe nodes | grep -A 5 "Allocated resources"

# Check PVC status
kubectl get pvc -A

# Check taints
kubectl describe nodes | grep Taints
```

---

### Issue 9: Control Plane Unresponsive After Restart

**Problem:** SSH works but `kubectl` commands timeout

**Solution:**
```bash
# SSH to control plane
ssh -i terraform/cka-simulator-key.pem ubuntu@<CONTROL_IP>

# Check kubelet
sudo systemctl status kubelet

# Check control plane pods
sudo crictl ps | grep kube-apiserver

# Restart kubelet
sudo systemctl restart kubelet

# Wait and test
sleep 60
kubectl get nodes
```

---

### Issue 10: Ingress Admission Webhook Timeout

**Problem:** Creating Ingress fails with webhook timeout

**Solution:**
```bash
# Delete the problematic webhook
kubectl delete validatingwebhookconfigurations ingress-nginx-admission

# Retry creating Ingress
kubectl apply -f your-ingress.yaml
```

---

## 📋 Quick Diagnostic Commands
```bash
# Cluster health
kubectl get nodes
kubectl get pods -A
kubectl top nodes

# Resource usage
kubectl describe nodes | grep -A 5 "Allocated resources"

# Events
kubectl get events -A --sort-by='.lastTimestamp' | head -20

# AWS resources
cd ~/Desktop/cka-simulator/terraform
terraform show | head -50

# Instance status
aws ec2 describe-instances \
  --filters "Name=tag:Project,Values=CKA-Simulator" \
  --query 'Reservations[*].Instances[*].[InstanceId,State.Name,PublicIpAddress]' \
  --output table
```

---

## 🆘 Still Having Issues?

1. **Check AWS Service Health:** https://status.aws.amazon.com/
2. **Open an Issue:** https://github.com/Tuhinzman/cka-simulator/issues
3. **LinkedIn:** https://www.linkedin.com/in/tuhinzaman/

**When reporting issues, include:**
- Error messages (full output)
- Output of `kubectl get nodes` and `kubectl get pods -A`
- AWS region
- Terraform version: `terraform version`
- Your OS

---

**Back to:** [README.md](README.md)
