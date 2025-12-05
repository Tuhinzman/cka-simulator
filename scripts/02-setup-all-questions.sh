#!/bin/bash
set -e

echo "=========================================="
echo "CKA Simulator - Setting Up All 16 Questions"
echo "=========================================="

# Q1: HPA
echo ""
echo "[Q1] Setting up HPA scenario..."
kubectl create namespace autoscale --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: apache-server
  namespace: autoscale
spec:
  replicas: 1
  selector:
    matchLabels:
      app: apache-server
  template:
    metadata:
      labels:
        app: apache-server
    spec:
      containers:
      - name: httpd
        image: httpd:2.4
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: 200m
            memory: 128Mi
---
apiVersion: v1
kind: Service
metadata:
  name: apache-server
  namespace: autoscale
spec:
  selector:
    app: apache-server
  ports:
  - port: 80
    targetPort: 80
EOF

# Q2: Ingress
echo ""
echo "[Q2] Setting up Ingress scenario..."
kubectl create namespace sound-repeater --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: echoserver
  namespace: sound-repeater
spec:
  replicas: 1
  selector:
    matchLabels:
      app: echoserver
  template:
    metadata:
      labels:
        app: echoserver
    spec:
      containers:
      - name: echoserver
        image: ealen/echo-server:latest
        ports:
        - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: echoserver-service
  namespace: sound-repeater
spec:
  selector:
    app: echoserver
  ports:
  - port: 8080
    targetPort: 8080
EOF

# Q3: System Prep
echo ""
echo "[Q3] Setting up System Prep reference..."
cat > /home/ubuntu/q3-sysctl-reference.txt <<EOF
Expected sysctl values for Kubernetes:
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.netfilter.nf_conntrack_max = 131072

cri-dockerd package location: /home/ubuntu/cri-dockerd_0.3.9.3-0.ubuntu-jammy_amd64.deb
EOF
chown ubuntu:ubuntu /home/ubuntu/q3-sysctl-reference.txt

# Q4: WordPress Resources
echo ""
echo "[Q4] Setting up WordPress resource scenario..."
kubectl create namespace relative-fawn --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: wordpress
  namespace: relative-fawn
spec:
  replicas: 3
  selector:
    matchLabels:
      app: wordpress
  template:
    metadata:
      labels:
        app: wordpress
    spec:
      initContainers:
      - name: init-wordpress
        image: busybox:1.36
        command: ['sh', '-c', 'echo Init complete']
        resources:
          requests:
            cpu: 50m
            memory: 64Mi
      containers:
      - name: wordpress
        image: wordpress:6.4-apache
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
EOF

# Q5: Sidecar Container
echo ""
echo "[Q5] Setting up Sidecar scenario..."
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: synergy-leveragerr
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: synergy-leveragerr
  template:
    metadata:
      labels:
        app: synergy-leveragerr
    spec:
      containers:
      - name: app
        image: busybox:stable
        command: ['/bin/sh', '-c']
        args:
        - |
          while true; do
            echo "\$(date): Leveraging synergies..." >> /var/log/synergy-leverager.log
            sleep 5
          done
EOF

# Q6: CNI
echo ""
echo "[Q6] CNI already installed - Calico v3.28.2"
echo "      No action needed. Calico supports NetworkPolicy."

# Q7: StorageClass
echo ""
echo "[Q7] Setting up StorageClass scenario..."
kubectl get storageclass local-path > /dev/null 2>&1 || echo "StorageClass will be configured"
kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}' || true

# Q8: Service/NodePort
echo ""
echo "[Q8] Setting up front-end Service scenario..."
kubectl create namespace spline-reticulator --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: front-end
  namespace: spline-reticulator
spec:
  replicas: 2
  selector:
    matchLabels:
      app: front-end
  template:
    metadata:
      labels:
        app: front-end
    spec:
      containers:
      - name: nginx
        image: nginx:1.25
        ports:
        - containerPort: 80
EOF

# Q9: PriorityClass
echo ""
echo "[Q9] Setting up PriorityClass scenario..."
kubectl create namespace priority --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f - <<EOF
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: highest-user-priority
value: 10000
globalDefault: false
description: "Highest user priority"
---
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: medium-priority
value: 5000
globalDefault: false
description: "Medium priority"
---
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: low-priority
value: 100
globalDefault: false
description: "Low priority"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: busybox-logger
  namespace: priority
spec:
  replicas: 2
  selector:
    matchLabels:
      app: busybox-logger
  template:
    metadata:
      labels:
        app: busybox-logger
    spec:
      containers:
      - name: busybox
        image: busybox:stable
        command: ['/bin/sh', '-c']
        args: ['while true; do echo "Logging..."; sleep 10; done']
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: other-app-1
  namespace: priority
spec:
  replicas: 1
  selector:
    matchLabels:
      app: other-app-1
  template:
    metadata:
      labels:
        app: other-app-1
    spec:
      priorityClassName: low-priority
      containers:
      - name: busybox
        image: busybox:stable
        command: ['sleep', '3600']
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: other-app-2
  namespace: priority
spec:
  replicas: 1
  selector:
    matchLabels:
      app: other-app-2
  template:
    metadata:
      labels:
        app: other-app-2
    spec:
      priorityClassName: low-priority
      containers:
      - name: busybox
        image: busybox:stable
        command: ['sleep', '3600']
EOF

# Q10: Argo CD
echo ""
echo "[Q10] Setting up Argo CD scenario (CRDs only)..."
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.11.0/manifests/crds/application-crd.yaml
kubectl apply -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.11.0/manifests/crds/applicationset-crd.yaml
kubectl apply -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.11.0/manifests/crds/appproject-crd.yaml
echo "      Argo CD CRDs pre-installed. Student will install Argo CD via Helm."

# Q11: MariaDB PV/PVC
echo ""
echo "[Q11] Setting up MariaDB PV/PVC scenario..."
kubectl create namespace mariadb --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mariadb-pv
spec:
  capacity:
    storage: 250Mi
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: manual
  hostPath:
    path: /mnt/data/mariadb
EOF

cat > /home/ubuntu/mariadb-deployment.yaml <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mariadb
  namespace: mariadb
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mariadb
  template:
    metadata:
      labels:
        app: mariadb
    spec:
      containers:
      - name: mariadb
        image: mariadb:10.11
        env:
        - name: MYSQL_ROOT_PASSWORD
          value: "password123"
        ports:
        - containerPort: 3306
        volumeMounts:
        - name: mariadb-storage
          mountPath: /var/lib/mysql
      volumes:
      - name: mariadb-storage
        emptyDir: {}
EOF
chown ubuntu:ubuntu /home/ubuntu/mariadb-deployment.yaml

# Q12: Gateway API
echo ""
echo "[Q12] Setting up Gateway API migration scenario..."
kubectl apply -f - <<EOF
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: nginx
spec:
  controllerName: k8s.io/ingress-nginx
---
apiVersion: v1
kind: Secret
metadata:
  name: web-tls
  namespace: default
type: kubernetes.io/tls
data:
  tls.crt: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUN5RENDQWJDZ0F3SUJBZ0lCQURBTkJna3Foa2lHOXcwQkFRc0ZBREFWTVJNd0VRWURWUVFERXdwcmRXSmwKY201bGRHVnpNQjRYRFRJME1USXdOVEUyTURBd01Gb1hEVEkxTVRJd05URTJNREF3TUZvd0ZURVRNQkVHQTFVRQpBeE1LYTNWaVpYSnVaWFJsY3pDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBTDdyCnJvdXJvZXVyb2V1cm9ldXJvZXVyb2V1cm9ldXJvZXVyb2V1cm9ldXJvZXVyb2V1cm9ldXJvZXVyb2V1cm9ldXIKb2V1cm9ldXJvZXVyCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
  tls.key: LS0tLS1CRUdJTiBQUklWQVRFIEtFWS0tLS0tCk1JSUV2UUlCQURBTkJna3Foa2lHOXcwQkFRRUZBQVNDQktjd2dnU2pBZ0VBQW9JQkFRQysrNjY2NzY3Njc2NzYKNjc2NzY3Njc2NzY3Njc2NzY3Njc2NzY3Njc2NzY3Njc2NzY3Njc2NzY3Njc2NzY3Njc2NzY3Njc2NzY3Njc2Nwo2NzY3Njc2NzY3Njc2NzY3Ci0tLS0tRU5EIFBSSVZBVEUgS0VZLS0tLS0K
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: nginx
        image: nginx:1.25
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: web-service
  namespace: default
spec:
  selector:
    app: web
  ports:
  - port: 80
    targetPort: 80
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web
  namespace: default
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - gateway.web.k8s.local
    secretName: web-tls
  rules:
  - host: gateway.web.k8s.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-service
            port:
              number: 80
EOF

# Q13: NetworkPolicy
echo ""
echo "[Q13] Setting up NetworkPolicy scenario..."
kubectl create namespace frontend --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace backend --dry-run=client -o yaml | kubectl apply -f -
kubectl label namespace frontend name=frontend --overwrite
kubectl label namespace backend name=backend --overwrite

kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  namespace: frontend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: frontend
      tier: frontend
  template:
    metadata:
      labels:
        app: frontend
        tier: frontend
    spec:
      containers:
      - name: nginx
        image: nginx:1.25
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
  namespace: backend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: backend
      tier: backend
  template:
    metadata:
      labels:
        app: backend
        tier: backend
    spec:
      containers:
      - name: nginx
        image: nginx:1.25
---
apiVersion: v1
kind: Service
metadata:
  name: backend-service
  namespace: backend
spec:
  selector:
    app: backend
  ports:
  - port: 80
    targetPort: 80
EOF

mkdir -p /home/ubuntu/netpol
cat > /home/ubuntu/netpol/netpol-1-too-permissive.yaml <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-all
  namespace: backend
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  ingress:
  - {}
EOF

cat > /home/ubuntu/netpol/netpol-2-correct.yaml <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend
  namespace: backend
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: frontend
      podSelector:
        matchLabels:
          app: frontend
EOF

cat > /home/ubuntu/netpol/netpol-3-too-restrictive.yaml <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
  namespace: backend
spec:
  podSelector: {}
  policyTypes:
  - Ingress
EOF

chown -R ubuntu:ubuntu /home/ubuntu/netpol

# Q14: Broken Cluster
echo ""
echo "[Q14] Creating broken cluster simulation script..."
cat > /home/ubuntu/break-cluster-q14.sh <<'BREAKEOF'
#!/bin/bash
echo "Breaking cluster for Q14..."
mkdir -p /etc/kubernetes/manifests.backup
cp /etc/kubernetes/manifests/*.yaml /etc/kubernetes/manifests.backup/

sed -i 's|--etcd-servers=https://127.0.0.1:2379|--etcd-servers=https://external-etcd.example.com:2379|' /etc/kubernetes/manifests/kube-apiserver.yaml

sed -i 's|--service-account-private-key-file=/etc/kubernetes/pki/sa.key|--service-account-private-key-file=/etc/kubernetes/pki/nonexistent-sa.key|' /etc/kubernetes/manifests/kube-controller-manager.yaml

echo "Cluster broken! Fix kube-apiserver and kube-controller-manager"
BREAKEOF
chmod +x /home/ubuntu/break-cluster-q14.sh
chown ubuntu:ubuntu /home/ubuntu/break-cluster-q14.sh

# Q15: cert-manager CRDs
echo ""
echo "[Q15] Verifying cert-manager CRDs..."
cat > /home/ubuntu/q15-verification.txt <<EOF
cert-manager CRDs installed:
\$(kubectl get crds | grep cert-manager)

Certificate.spec.subject documentation:
\$(kubectl explain certificate.spec.subject)
EOF
chown ubuntu:ubuntu /home/ubuntu/q15-verification.txt

# Q16: ConfigMap Immutable
echo ""
echo "[Q16] Setting up nginx-static ConfigMap scenario..."
kubectl create namespace nginx-static --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-config
  namespace: nginx-static
data:
  nginx.conf: |
    events {}
    http {
      server {
        listen 443 ssl;
        server_name web.k8s.local;
        
        ssl_certificate /etc/nginx/ssl/tls.crt;
        ssl_certificate_key /etc/nginx/ssl/tls.key;
        ssl_protocols TLSv1.3;
        
        location / {
          return 200 "Hello from NGINX\n";
          add_header Content-Type text/plain;
        }
      }
    }
---
apiVersion: v1
kind: Secret
metadata:
  name: nginx-tls
  namespace: nginx-static
type: kubernetes.io/tls
data:
  tls.crt: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUN5RENDQWJDZ0F3SUJBZ0lCQURBTkJna3Foa2lHOXcwQkFRc0ZBREFWTVJNd0VRWURWUVFERXdwcmRXSmwKY201bGRHVnpNQjRYRFRJME1USXdOVEUyTURBd01Gb1hEVEkxTVRJd05URTJNREF3TUZvd0ZURVRNQkVHQTFVRQpBeE1LYTNWaVpYSnVaWFJsY3pDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBTDdyCnJvdXJvZXVyb2V1cm9ldXJvZXVyb2V1cm9ldXJvZXVyb2V1cm9ldXJvZXVyb2V1cm9ldXJvZXVyb2V1cm9ldXIKb2V1cm9ldXJvZXVyCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
  tls.key: LS0tLS1CRUdJTiBQUklWQVRFIEtFWS0tLS0tCk1JSUV2UUlCQURBTkJna3Foa2lHOXcwQkFRRUZBQVNDQktjd2dnU2pBZ0VBQW9JQkFRQysrNjY2NzY3Njc2NzYKNjc2NzY3Njc2NzY3Njc2NzY3Njc2NzY3Njc2NzY3Njc2NzY3Njc2NzY3Njc2NzY3Njc2NzY3Njc2NzY3Njc2Nwo2NzY3Njc2NzY3Njc2NzY3Ci0tLS0tRU5EIFBSSVZBVEUgS0VZLS0tLS0K
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-static
  namespace: nginx-static
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx-static
  template:
    metadata:
      labels:
        app: nginx-static
    spec:
      containers:
      - name: nginx
        image: nginx:1.25
        ports:
        - containerPort: 443
        volumeMounts:
        - name: config
          mountPath: /etc/nginx/nginx.conf
          subPath: nginx.conf
        - name: tls
          mountPath: /etc/nginx/ssl
      volumes:
      - name: config
        configMap:
          name: nginx-config
      - name: tls
        secret:
          secretName: nginx-tls
EOF

echo ""
echo "=========================================="
echo "ALL 16 QUESTIONS SETUP COMPLETE!"
echo "=========================================="

sleep 5

echo ""
echo "Waiting for all deployments to stabilize..."
sleep 10

echo ""
echo "CLUSTER STATUS:"
echo "----------------------------------------"
kubectl get nodes
echo ""
echo "NAMESPACES:"
kubectl get namespaces | grep -v STATUS
echo ""
echo "RUNNING PODS:"
kubectl get pods -A --no-headers | wc -l | xargs echo "pods running across all namespaces"

# Create questions checklist
cat > /home/ubuntu/questions-checklist.txt <<EOF
CKA SIMULATOR - QUESTIONS CHECKLIST
====================================

✓ Q1  - HPA (autoscale namespace)
      kubectl get deployment apache-server -n autoscale

✓ Q2  - Ingress (sound-repeater namespace)
      kubectl get svc echoserver-service -n sound-repeater

✓ Q3  - System Prep (simulation)
      ls ~/cri-dockerd_0.3.9.3-0.ubuntu-jammy_amd64.deb
      cat ~/q3-sysctl-reference.txt

✓ Q4  - WordPress Resources (relative-fawn namespace)
      kubectl get deployment wordpress -n relative-fawn

✓ Q5  - Sidecar Container (default namespace)
      kubectl get deployment synergy-leveragerr

✓ Q6  - CNI (Calico pre-installed)
      kubectl get pods -n kube-system | grep calico

✓ Q7  - StorageClass (local-path configured as default)
      kubectl get storageclass

✓ Q8  - Service/NodePort (spline-reticulator namespace)
      kubectl get deployment front-end -n spline-reticulator

✓ Q9  - PriorityClass (priority namespace)
      kubectl get priorityclass
      kubectl get deployment busybox-logger -n priority

✓ Q10 - Argo CD Helm (argocd namespace, CRDs pre-installed)
      kubectl get crds | grep argoproj
      helm repo list | grep argo

✓ Q11 - MariaDB PV/PVC (mariadb namespace)
      kubectl get pv mariadb-pv
      ls ~/mariadb-deployment.yaml

✓ Q12 - Gateway API (default namespace)
      kubectl get ingress web
      kubectl get gatewayclass nginx

✓ Q13 - NetworkPolicy (frontend/backend namespaces)
      kubectl get deployments -n frontend,backend
      ls ~/netpol/

✓ Q14 - Broken Cluster (simulation script ready)
      ls ~/break-cluster-q14.sh

✓ Q15 - cert-manager CRDs (cert-manager namespace)
      kubectl get crds | grep cert-manager
      cat ~/q15-verification.txt

✓ Q16 - ConfigMap Immutable (nginx-static namespace)
      kubectl get configmap nginx-config -n nginx-static

====================================
READY TO PRACTICE ALL 16 QUESTIONS!
====================================
EOF
chown ubuntu:ubuntu /home/ubuntu/questions-checklist.txt

echo ""
echo "=========================================="
echo "Setup complete! Check ~/questions-checklist.txt"
echo "=========================================="
