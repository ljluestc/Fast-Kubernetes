# LAB: Kubernetes Services

## ClusterIP · NodePort · LoadBalancer · Service Discovery

---

## Overview

This lab demonstrates **Kubernetes Services** - the networking layer that enables pod-to-pod communication and external access:

You will learn how to:

* Create **ClusterIP Services** (internal cluster communication)
* Create **NodePort Services** (external access via node ports)
* Create **LoadBalancer Services** (cloud load balancers)
* Understand **service discovery** and DNS
* Test **service-to-service communication**
* Access services from **outside the cluster**

---

## Environment (IMPORTANT)

This lab assumes:

| Component  | Value                      |
| ---------- | -------------------------- |
| OS         | macOS                      |
| Kubernetes | kubeadm                    |
| VM         | Multipass                  |
| CNI        | Flannel                    |
| kubectl    | Installed on macOS         |
| Cluster    | 1 control-plane + 1 worker |

### Required kubeconfig

```bash
export KUBECONFIG=~/.kube/multipass-admin.conf
```

Make it permanent:

```bash
echo 'export KUBECONFIG=~/.kube/multipass-admin.conf' >> ~/.zshrc
source ~/.zshrc
```

Verify cluster access:

```bash
kubectl get nodes
```

Both nodes must be `Ready`.

---

## kubectl Configuration Troubleshooting

If you see `localhost:8080` errors, your kubeconfig is not loaded. Run these fixes:

```bash
# 1. Verify kubeconfig exists
ls -l ~/.kube/multipass-admin.conf

# 2. Symlink to default location
mkdir -p ~/.kube
rm -f ~/.kube/config
ln -s ~/.kube/multipass-admin.conf ~/.kube/config

# 3. Export environment variable
export KUBECONFIG=$HOME/.kube/config

# 4. Verify kubectl sees the config
kubectl config view --minify
kubectl get nodes
```

---

## Step 1: Create Frontend & Backend Deployments

Create both deployments in a single YAML file:

```bash
cat <<'EOF' > deployments.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  labels:
    team: development
spec:
  replicas: 3
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
      - name: frontend
        image: nginx:latest
        ports:
        - containerPort: 80
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
  labels:
    team: development
spec:
  replicas: 3
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
      - name: backend
        image: ozgurozturknet/k8s:backend
        ports:
        - containerPort: 5000
EOF
```

Apply the deployments:

```bash
kubectl apply -f deployments.yaml
```

Verify deployments and pods:

```bash
kubectl get deployments
kubectl get pods -l app=frontend
kubectl get pods -l app=backend
```

Expected: **6 pods total** (3 frontend + 3 backend)

---

## Step 2: Create ClusterIP Service (Internal Communication)

Create a ClusterIP service for the backend:

```bash
cat <<'EOF' > backend-clusterip.yaml
apiVersion: v1
kind: Service
metadata:
  name: backend
spec:
  type: ClusterIP
  selector:
    app: backend
  ports:
    - protocol: TCP
      port: 5000
      targetPort: 5000
EOF
```

Apply the service:

```bash
kubectl apply -f backend-clusterip.yaml
```

Check the service:

```bash
kubectl get services
kubectl describe service backend
```

Expected output shows:
- **ClusterIP**: An internal IP (e.g., 10.96.x.x)
- **Port**: 5000
- **Endpoints**: 3 backend pods

---

## Step 3: Test ClusterIP Service (Service Discovery)

### Method 1: From a Frontend Pod

Get a frontend pod name and connect:

```bash
FRONTEND_POD=$(kubectl get pods -l app=frontend -o jsonpath='{.items[0].metadata.name}')
kubectl exec -it $FRONTEND_POD -- sh
```

Inside the pod, test service discovery:

```sh
# Check DNS resolution
nslookup backend

# Expected: backend.default.svc.cluster.local

# Test service connectivity
curl http://backend:5000

# Expected: Response from backend service
```

Exit the pod:

```sh
exit
```

### Method 2: From Another Pod

Create a test pod to verify:

```bash
kubectl run test-pod --image=busybox --rm -it --restart=Never -- wget --timeout=5 -qO- http://backend:5000
```

---

## Step 4: Create NodePort Service (External Access)

Create a NodePort service for the frontend:

```bash
cat <<'EOF' > frontend-nodeport.yaml
apiVersion: v1
kind: Service
metadata:
  name: frontend
spec:
  type: NodePort
  selector:
    app: frontend
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
      nodePort: 30080  # Optional: specify port, or let k8s assign
EOF
```

Apply the service:

```bash
kubectl apply -f frontend-nodeport.yaml
```

Check the service:

```bash
kubectl get services
kubectl describe service frontend
```

Expected output shows:
- **Type**: NodePort
- **NodePort**: 30080 (or assigned port)
- **Endpoints**: 3 frontend pods

---

## Step 5: Test NodePort Service

### Method 1: From macOS (External Access)

Get the worker node IP:

```bash
multipass info k8s-worker-node
# Note the IPv4 address
```

Test access from your Mac:

```bash
curl http://<WORKER-NODE-IP>:30080
```

Expected: nginx welcome page

### Method 2: From Control Plane

SSH into control plane and test:

```bash
multipass shell k8s-control-plane
curl http://<WORKER-NODE-IP>:30080
exit
```

### Method 3: From Another Pod

```bash
kubectl run test-access --image=busybox --rm -it --restart=Never -- wget --timeout=5 -qO- http://<WORKER-NODE-IP>:30080
```

---

## Step 6: Create LoadBalancer Service

**Note**: LoadBalancer services require cloud provider integration. In local clusters, they remain in "Pending" state.

Create a LoadBalancer service:

```bash
cat <<'EOF' > frontend-loadbalancer.yaml
apiVersion: v1
kind: Service
metadata:
  name: frontend-lb
spec:
  type: LoadBalancer
  selector:
    app: frontend
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
EOF
```

Apply the service:

```bash
kubectl apply -f frontend-loadbalancer.yaml
```

Check the service:

```bash
kubectl get services
kubectl describe service frontend-lb
```

Expected output shows:
- **Type**: LoadBalancer
- **External-IP**: `<pending>` (in local cluster)
- **Port**: 80

**Note**: For actual LoadBalancer functionality, deploy to:
- AWS EKS
- Azure AKS
- Google GKE
- Other cloud providers

---

## Step 7: Service Comparison & Testing

### Test All Services

```bash
# List all services
kubectl get services

# Test ClusterIP (internal)
kubectl exec -it $FRONTEND_POD -- curl http://backend:5000

# Test NodePort (external)
curl http://<WORKER-IP>:30080

# Test LoadBalancer (would work in cloud)
# kubectl get service frontend-lb
```

### Service Types Summary

| Type | Internal Access | External Access | Cloud Required | Use Case |
|------|----------------|-----------------|---------------|-----------|
| **ClusterIP** | ✅ | ❌ | No | Internal pod-to-pod |
| **NodePort** | ✅ | ✅ | No | Development/testing |
| **LoadBalancer** | ✅ | ✅ | Yes | Production external access |

---

## Step 8: Imperative Service Creation

You can also create services imperatively:

```bash
# Create ClusterIP service
kubectl expose deployment backend --type=ClusterIP --name=backend-imperative --port=5000 --target-port=5000

# Create NodePort service
kubectl expose deployment frontend --type=NodePort --name=frontend-imperative --port=80 --target-port=80

# List all services
kubectl get services
```

---

## Step 9: Service Debugging

### Check Service Endpoints

```bash
# View service endpoints
kubectl get endpoints

# Describe specific service
kubectl describe service backend

# Check if pods match selectors
kubectl get pods --show-labels
```

### Common Issues

#### Service Not Routing Traffic
```bash
# Check if pods match service selector
kubectl get pods -l app=backend

# Check service endpoints
kubectl get endpoints backend

# Verify pod ports
kubectl describe pod <backend-pod>
```

#### DNS Resolution Issues
```bash
# Test DNS from a pod
kubectl exec -it $FRONTEND_POD -- nslookup backend

# Check CoreDNS pods
kubectl get pods -n kube-system -l k8s-app=kube-dns
```

---

## Step 10: Cleanup

Delete all resources:

```bash
kubectl delete service backend frontend frontend-lb backend-imperative frontend-imperative
kubectl delete deployment frontend backend
kubectl delete -f deployments.yaml backend-clusterip.yaml frontend-nodeport.yaml frontend-loadbalancer.yaml
```

Verify cleanup:

```bash
kubectl get services
kubectl get deployments
kubectl get pods
```

---

## Key Takeaways (Interview-Level)

| Concept | Demonstrated |
|---------|-------------|
| **Service Types** | ClusterIP, NodePort, LoadBalancer |
| **Service Discovery** | DNS-based service resolution |
| **Load Balancing** | Round-robin across pods |
| **External Access** | NodePort for development |
| **Selectors** | Pod-to-service matching |
| **Endpoints** | Dynamic pod IP tracking |

---

## Production Considerations

* **ClusterIP**: Default choice for internal communication
* **NodePort**: Good for development, limited scalability
* **LoadBalancer**: Production external access with cloud providers
* **Annotations**: Add cloud-specific configurations
* **Health Checks**: Configure readiness probes for better load balancing

---

## Next Recommended Labs

1. **Ingress** - HTTP routing and SSL termination
2. **ConfigMaps & Secrets** - Application configuration
3. **Persistent Volumes** - Data persistence
4. **Network Policies** - Traffic control
5. **Horizontal Pod Autoscaler** - Auto-scaling
