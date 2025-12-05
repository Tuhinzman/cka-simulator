# CKA Exam Simulator - বাংলা গাইড

AWS-এ Kubernetes ক্লাস্টার তৈরি করে CKA পরীক্ষার প্র্যাকটিস করার সম্পূর্ণ বাংলা গাইড।

## শুরুর কথা

এই প্রজেক্ট দিয়ে আপনি AWS-এ একটি সম্পূর্ণ Kubernetes ক্লাস্টার তৈরি করতে পারবেন।

**কি কি পাবেন:**
- Kubernetes v1.31.0 (1 মাস্টার + 3 ওয়ার্কার)
- সব 16টি CKA প্রশ্ন প্রি-কনফিগার
- Terraform দিয়ে অটোমেটিক সেটাপ
- কম খরচ (~$4/দিন)

## প্রয়োজনীয় জিনিসপত্র

### সফটওয়্যার ইনস্টল
```bash
brew install terraform awscli git
```

## AWS সেটাপ

1. AWS একাউন্ট তৈরি করুন
2. IAM user তৈরি করুন
3. AWS CLI কনফিগার করুন
```bash
aws configure
```

## ইনস্টলেশন

### ধাপ 1: Repository ডাউনলোড
```bash
git clone https://github.com/Tuhinzman/cka-simulator.git
cd cka-simulator
```

### ধাপ 2: IP Setup
```bash
cd terraform
MY_IP=$(curl -4 -s ifconfig.me)
cat > terraform.tfvars <<CONFIG
my_ip        = "${MY_IP}/32"
aws_region   = "us-east-1"
cluster_name = "cka-simulator"
worker_count = 3
CONFIG
```

### ধাপ 3: Infrastructure তৈরি
```bash
terraform init
terraform apply
sleep 180
```

### ধাপ 4: Scripts কপি
```bash
CONTROL_IP=$(terraform output -raw control_plane_public_ip)
cd ..
scp -i terraform/cka-simulator-key.pem scripts/*.sh ubuntu@${CONTROL_IP}:/home/ubuntu/
```

### ধাপ 5: Cluster তৈরি
```bash
ssh -i terraform/cka-simulator-key.pem ubuntu@${CONTROL_IP}
chmod +x /home/ubuntu/*.sh
sudo /home/ubuntu/00-bootstrap-cluster.sh
```

Join command কপি করুন!

### ধাপ 6: Workers যোগ করুন

প্রতিটি worker-এ join command চালান।

### ধাপ 7: Addons ইনস্টল
```bash
sudo /home/ubuntu/01-install-addons.sh
sudo /home/ubuntu/02-setup-all-questions.sh
```

## প্র্যাকটিস প্রশ্ন

### প্রশ্ন 1: HPA
```bash
kubectl autoscale deployment apache-server \
  --namespace=autoscale \
  --cpu-percent=50 \
  --min=1 \
  --max=4
```

সম্পূর্ণ গাইড: [PRACTICE_GUIDE.md](PRACTICE_GUIDE.md)

## সমস্যা সমাধান

### SSH কানেক্ট হচ্ছে না
```bash
MY_IP=$(curl -4 -s ifconfig.me)
cat > terraform/terraform.tfvars <<CONFIG
my_ip = "${MY_IP}/32"
aws_region = "us-east-1"
cluster_name = "cka-simulator"
worker_count = 3
CONFIG
terraform apply -auto-approve
```

### Instances বন্ধ করুন
```bash
cd terraform
aws ec2 stop-instances --instance-ids $(terraform show -json | jq -r '.values.root_module.resources[] | select(.type=="aws_instance") | .values.id' | tr '\n' ' ')
```

### সব মুছুন
```bash
terraform destroy -auto-approve
```

## খরচ

- চালু: ~$4/দিন (৳440)
- বন্ধ: প্রায় ফ্রি

## যোগাযোগ

- GitHub: https://github.com/Tuhinzman/cka-simulator
- LinkedIn: https://www.linkedin.com/in/tuhinzaman/

---

**তৈরি করেছেন:** Tuhin Zaman  
**বাংলাদেশী DevOps Engineers-দের জন্য ❤️**
