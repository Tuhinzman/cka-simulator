# CKA Simulator - Windows Setup Guide

Complete guide for Windows users to set up the CKA practice environment.

## Prerequisites

- Windows 10/11 (64-bit)
- Administrator access
- 8GB+ RAM
- AWS account

## Step 1: Install WSL2

Open PowerShell as Administrator:
```powershell
wsl --install
```

Restart computer, then:
```powershell
wsl --set-default-version 2
wsl --install -d Ubuntu-22.04
```

## Step 2: Install Tools in Ubuntu
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Terraform
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform -y

# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt install unzip -y
unzip awscliv2.zip
sudo ./aws/install

# Install Git and jq
sudo apt install git jq -y
```

## Step 3: AWS Setup

Configure AWS:
```bash
aws configure
```

Enter your credentials.

## Step 4: Deploy
```bash
cd ~
git clone https://github.com/Tuhinzman/cka-simulator.git
cd cka-simulator/terraform

MY_IP=$(curl -4 -s ifconfig.me)
cat > terraform.tfvars <<EOF
my_ip        = "${MY_IP}/32"
aws_region   = "us-east-1"
cluster_name = "cka-simulator"
worker_count = 3
EOF

terraform init
terraform apply
```

## Step 5: Setup Cluster

Follow the same steps as in [README.md](README.md)

## Troubleshooting

### WSL2 Kernel Update Required

Download: https://aka.ms/wsl2kernel

### SSH Issues
```bash
chmod 600 ~/cka-simulator/terraform/cka-simulator-key.pem
```

### Access WSL Files from Windows
```
\\wsl$\Ubuntu-22.04\home\yourname\cka-simulator
```

## Resources

- [Full Guide](README.md)
- [Practice Guide](PRACTICE_GUIDE.md)
- [Troubleshooting](TROUBLESHOOTING.md)

---

**Created by:** Tuhin Zaman
