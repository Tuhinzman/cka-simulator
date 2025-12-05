# CKA Exam Simulator - Complete AWS Environment

A production-ready Certified Kubernetes Administrator (CKA) exam practice environment deployed on AWS using Terraform. This simulator includes all 16 common CKA exam scenarios pre-configured and ready to practice.

[![Kubernetes](https://img.shields.io/badge/Kubernetes-v1.31.0-326CE5?logo=kubernetes)](https://kubernetes.io/)
[![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.5-7B42BC?logo=terraform)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-EC2-FF9900?logo=amazon-aws)](https://aws.amazon.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Cost Estimate](#cost-estimate)
- [Quick Start](#quick-start)
- [Practice Questions](#practice-questions)
- [Cost Management](#cost-management)
- [Troubleshooting](#troubleshooting)
- [Cleanup](#cleanup)
- [Contributing](#contributing)

## 🎯 Overview

This project creates a complete Kubernetes cluster on AWS with all CKA exam scenarios pre-configured. Perfect for:

- **CKA Exam Preparation**: Practice all common exam scenarios
- **Hands-on Learning**: Real Kubernetes cluster (not minikube/kind)
- **Repeatable Environment**: Destroy and recreate anytime
- **Cost-Effective**: ~$0.17/hour, stop when not practicing

## ✨ Features

### Infrastructure
- ✅ Kubernetes v1.31.0 cluster (kubeadm)
- ✅ 1 Control Plane + 3 Worker Nodes (t3.medium)
- ✅ Calico CNI with NetworkPolicy support
- ✅ AWS VPC with public subnets across 2 AZs
- ✅ Auto-generated SSH keys
- ✅ Encrypted EBS volumes

### Pre-installed Components
- ✅ Metrics Server (for HPA)
- ✅ NGINX Ingress Controller
- ✅ Gateway API CRDs
- ✅ cert-manager
- ✅ Local Path Provisioner (default StorageClass)
- ✅ Helm 3
- ✅ Argo CD Helm repository

### All 16 CKA Practice Questions
1. HorizontalPodAutoscaler (HPA)
2. Ingress
3. System Preparation
4. Resource Requests/Limits
5. Sidecar Container
6. CNI Installation
7. StorageClass
8. Service with NodePort
9. PriorityClass
10. Argo CD with Helm
11. PersistentVolume/PVC
12. Gateway API
13. NetworkPolicy
14. Broken Cluster Troubleshooting
15. cert-manager CRDs
16. Immutable ConfigMap

## 💰 Cost Estimate

| Resource | Cost/Hour | Cost/Day |
|----------|-----------|----------|
| 4x t3.medium instances | $0.166 | ~$4.00 |
| Storage + Data Transfer | $0.004 | ~$0.10 |
| **TOTAL** | **~$0.17/hour** | **~$4/day** |

**💡 Tip:** Stop instances when not practicing to save ~70% of costs!

## 🚀 Quick Start
```bash
# 1. Clone repository
git clone https://github.com/Tuhinzman/cka-simulator.git
cd cka-simulator

# 2. Configure your IP
export MY_IP=$(curl -4 -s ifconfig.me)
cat > terraform/terraform.tfvars <<EOF
my_ip        = "${MY_IP}/32"
aws_region   = "us-east-1"
cluster_name = "cka-simulator"
worker_count = 3
EOF

# 3. Deploy infrastructure
cd terraform
terraform init
terraform apply
sleep 180

# 4. Copy setup scripts
export CONTROL_IP=$(terraform output -raw control_plane_public_ip)
cd ..
scp -i terraform/cka-simulator-key.pem scripts/*.sh ubuntu@${CONTROL_IP}:/home/ubuntu/

# 5. SSH and bootstrap
ssh -i terraform/cka-simulator-key.pem ubuntu@${CONTROL_IP}
chmod +x /home/ubuntu/*.sh
sudo /home/ubuntu/00-bootstrap-cluster.sh

# 6. Join workers (copy join command, run on each worker)
# sudo kubeadm join ...

# 7. Install addons and setup questions
sudo /home/ubuntu/01-install-addons.sh
sudo /home/ubuntu/02-setup-all-questions.sh

# 8. Start practicing!
cat ~/questions-checklist.txt
```

**Total Setup Time:** ~35-50 minutes

## 📚 Full Documentation

For complete setup guide, troubleshooting, and all 16 question solutions, see the detailed guides in the repository.

## 🔧 Quick Commands
```bash
# Check cluster health
kubectl get nodes
kubectl get pods -A

# View questions
cat ~/questions-checklist.txt

# Test metrics
kubectl top nodes
```

## 🗑️ Cleanup
```bash
cd ~/cka-simulator/terraform
terraform destroy -auto-approve
```

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Kubernetes Documentation
- CKA Exam Curriculum
- Terraform AWS Provider
- Calico CNI Project

## ⭐ Support

If this helped you, please give it a star! ⭐

**Repository:** https://github.com/Tuhinzman/cka-simulator

---

**Made with ❤️ for CKA exam preparation**

## 👤 Author

**Tuhin Zaman**
- 🔗 LinkedIn: [linkedin.com/in/tuhinzaman](https://www.linkedin.com/in/tuhinzaman/)
- 🐙 GitHub: [@Tuhinzman](https://github.com/Tuhinzman)
- 💼 Role: Cloud DevOps Engineer
- 🎯 Certifications: AWS Solutions Architect Associate, CKA (In Progress)

## 📞 Contact & Support

- **LinkedIn:** https://www.linkedin.com/in/tuhinzaman/
- **Issues:** https://github.com/Tuhinzman/cka-simulator/issues
- **Discussions:** https://github.com/Tuhinzman/cka-simulator/discussions

💬 Feel free to reach out for questions, feedback, or collaboration opportunities!

