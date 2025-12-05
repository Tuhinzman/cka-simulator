output "control_plane_public_ip" {
  description = "Public IP address of control plane node"
  value       = aws_instance.control_plane.public_ip
}

output "control_plane_private_ip" {
  description = "Private IP address of control plane node"
  value       = aws_instance.control_plane.private_ip
}

output "worker_public_ips" {
  description = "Public IP addresses of worker nodes"
  value       = aws_instance.worker[*].public_ip
}

output "worker_private_ips" {
  description = "Private IP addresses of worker nodes"
  value       = aws_instance.worker[*].private_ip
}

output "ssh_key_path" {
  description = "Path to SSH private key"
  value       = var.ssh_key_name != "" ? "Use your existing key: ${var.ssh_key_name}" : "${var.cluster_name}-key.pem"
}

output "ssh_command_control_plane" {
  description = "SSH command to connect to control plane"
  value       = "ssh -i ${var.ssh_key_name != "" ? var.ssh_key_name : "${var.cluster_name}-key.pem"} ubuntu@${aws_instance.control_plane.public_ip}"
}

output "next_steps" {
  description = "Next steps to complete setup"
  value       = <<-EOT
    
    ========================================
    CKA SIMULATOR - INFRASTRUCTURE READY
    ========================================
    
    Control Plane IP: ${aws_instance.control_plane.public_ip}
    
    Next commands:
    
    export CONTROL_IP=${aws_instance.control_plane.public_ip}
    sleep 180
    scp -i terraform/cka-simulator-key.pem scripts/*.sh ubuntu@$CONTROL_IP:/home/ubuntu/
    ssh -i terraform/cka-simulator-key.pem ubuntu@$CONTROL_IP
    
    Then on control plane:
    chmod +x /home/ubuntu/*.sh
    sudo /home/ubuntu/00-bootstrap-cluster.sh
    
    ========================================
  EOT
}

output "cluster_info" {
  description = "Cluster information"
  value = {
    cluster_name         = var.cluster_name
    kubernetes_version   = var.kubernetes_version
    control_plane_ip     = aws_instance.control_plane.public_ip
    worker_count         = var.worker_count
    estimated_cost_hour  = format("$%.2f", (var.worker_count + 1) * 0.0416)
  }
}
