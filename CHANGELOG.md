# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-12-05

### Added
- Initial release
- Complete Terraform infrastructure for AWS
- Kubernetes v1.31.0 cluster setup
- All 16 CKA practice questions pre-configured
- Automated setup scripts
- Comprehensive documentation
- Cost management guides
- Troubleshooting section

### Infrastructure
- 1 Control Plane + 3 Worker Nodes (t3.medium)
- Calico CNI v3.28.2
- NGINX Ingress Controller v1.11.1
- Metrics Server v0.7.1
- cert-manager v1.15.0
- Gateway API v1.1.0
- Local Path Provisioner v0.0.28

### Practice Questions
- Q1: HorizontalPodAutoscaler (HPA)
- Q2: Ingress
- Q3: System Preparation
- Q4: Resource Requests/Limits
- Q5: Sidecar Container
- Q6: CNI Installation
- Q7: StorageClass
- Q8: Service with NodePort
- Q9: PriorityClass
- Q10: Argo CD with Helm
- Q11: PersistentVolume/PVC
- Q12: Gateway API
- Q13: NetworkPolicy
- Q14: Broken Cluster Troubleshooting
- Q15: cert-manager CRDs
- Q16: Immutable ConfigMap

## [Unreleased]

### Planned
- Support for other cloud providers (GCP, Azure)
- Additional practice scenarios
- Video tutorials
- Automated testing

---

[1.0.0]: https://github.com/YOUR_USERNAME/cka-simulator/releases/tag/v1.0.0
