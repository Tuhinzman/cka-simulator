variable "aws_region" {
  description = "AWS region for the CKA simulator"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
  default     = "cka-simulator"
}

variable "kubernetes_version" {
  description = "Kubernetes version to install"
  type        = string
  default     = "1.31"
}

variable "pod_network_cidr" {
  description = "CIDR for pod network (Calico default)"
  type        = string
  default     = "192.168.0.0/16"
}

variable "control_plane_instance_type" {
  description = "EC2 instance type for control plane"
  type        = string
  default     = "t3.medium"
}

variable "worker_instance_type" {
  description = "EC2 instance type for worker nodes"
  type        = string
  default     = "t3.medium"
}

variable "worker_count" {
  description = "Number of worker nodes"
  type        = number
  default     = 3
}

variable "my_ip" {
  description = "Your public IP address for SSH access (CIDR format)"
  type        = string
}

variable "ssh_key_name" {
  description = "Name of existing AWS SSH key pair (leave empty to create new)"
  type        = string
  default     = ""
}

variable "enable_mariadb_volume" {
  description = "Create EBS volume for Q11 MariaDB scenario"
  type        = bool
  default     = true
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Project     = "CKA-Simulator"
    Environment = "Practice"
    ManagedBy   = "Terraform"
  }
}
