# Quick Start Guide - CKA Simulator

Fast setup guide to recreate your CKA practice environment.

## Prerequisites

- AWS CLI configured
- Terraform installed

## Quick Setup

### Step 1: Deploy Infrastructure
```bash
cd ~/Desktop/cka-simulator/terraform

MY_IP=$(curl -4 -s ifconfig.me)
cat > terraform.tfvars <<TFVARS
my_ip        = "${MY_IP}/32"
aws_region   = "us-east-1"
cluster_name = "cka-simulator"
worker_count = 3
TFVARS

terraform apply -auto-approve
sleep 180
```

### Step 2: Copy Scripts
```bash
CONTROL_IP=$(terraform output -raw control_plane_public_ip)
cd ..
scp -i terraform/cka-simulator-key.pem scripts/*.sh ubuntu@${CONTROL_IP}:/home/ubuntu/
```

### Step 3: Setup Cluster
```bash
ssh -i terraform/cka-simulator-key.pem ubuntu@${CONTROL_IP}
chmod +x /home/ubuntu/*.sh
sudo /home/ubuntu/00-bootstrap-cluster.sh
```

Copy the join command!

### Step 4: Join Workers

Join each worker with the command from Step 3.

### Step 5: Install Addons
```bash
sudo /home/ubuntu/01-install-addons.sh
sudo /home/ubuntu/02-setup-all-questions.sh
```

## Destroy When Done
```bash
cd ~/Desktop/cka-simulator/terraform
terraform destroy -auto-approve
```

---

**See [README.md](README.md) for detailed guide.**