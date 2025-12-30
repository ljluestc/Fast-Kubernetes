## LAB: K8s Deployment - Scale Up/Down - Bash Connection - Port Forwarding

This scenario shows:
- how to create deployment,
- how to get detail information of deployment and pods,
- how to scale up and down of deployment,
- how to connect to the one of the pods with bash,
- how to show ethernet interfaces of the pod and ping other pods,
- how to forward ports to see nginx server page using browser.

### Environment Setup

**Prerequisites:** This lab assumes you have a running Kubernetes cluster set up with kubeadm on Multipass VMs.

- Control plane: `k8s-control-plane` (IP: 192.168.64.2)
- Worker node: `k8s-worker-node` (IP: 192.168.64.3)
- CNI: Flannel
- kubectl configured on macOS: `export KUBECONFIG=~/.kube/multipass-admin.conf`

**Verify cluster is ready:**
```bash
kubectl get nodes
kubectl get pods -A
```

If you need to set up the cluster first, follow the [complete local setup guide](../QUICKSTART.md).
  
### Step 1: Create Deployment YAML

Create a deployment YAML file:

```bash
cat <<'EOF' > deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: firstdeployment
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
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
EOF
```

**Apply the deployment:**
```bash
kubectl apply -f deployment.yaml
```

**Check deployment status:**
```bash
kubectl get deployments
kubectl describe deployment firstdeployment
```

**Note:** If pods show 0/3 READY initially, this is normal. The scheduler needs time to create and schedule the pods. Continue with scaling commands.


### Step 2: Scale the Deployment

**Scale up to 5 replicas:**
```bash
kubectl scale deployment firstdeployment --replicas=5
kubectl get deployment firstdeployment
```

**Scale down to 3 replicas:**
```bash
kubectl scale deployment firstdeployment --replicas=3
kubectl get deployment firstdeployment
```

**Monitor pods in real-time:**
```bash
kubectl get pods -l app=frontend -w
```

### Step 3: Self-Healing Demonstration

**Delete a pod to trigger self-healing:**
```bash
# Get pod names
kubectl get pods -l app=frontend

# Delete one pod (replace with actual pod name)
kubectl delete pod firstdeployment-xxxxx-xxxxx

# Watch Kubernetes recreate it automatically
kubectl get pods -l app=frontend -w
```

**Expected result:** A new pod is automatically created to maintain the desired replica count.

### Step 4: Troubleshooting Pod Creation Issues

If pods remain in ContainerCreating status or don't appear:

**Check pod status:**
```bash
kubectl get pods -l app=frontend -o wide
kubectl describe pod <pod-name>
```

**Common issues:**
- **Image pull errors:** Check if nginx:latest can be pulled
- **Resource constraints:** Insufficient CPU/memory on nodes
- **Node scheduling issues:** Check node status with `kubectl describe node`

**Force pod recreation:**
```bash
kubectl scale deployment firstdeployment --replicas=0
kubectl scale deployment firstdeployment --replicas=3
```

### Step 5: Get Pod Information

**List pods with detailed information:**
```bash
kubectl get pods -l app=frontend -o wide
```

**Describe a specific pod:**
```bash
kubectl describe pod <pod-name>
```

### Step 6: Connect to Pod Shell

**Get a pod name and connect:**
```bash
POD=$(kubectl get pods -l app=frontend -o jsonpath='{.items[0].metadata.name}')
kubectl exec -it $POD -- sh
```

**Inside the pod, install networking tools:**
```bash
apt update
apt install -y iputils-ping net-tools
```

**Check network interfaces:**
```bash
ifconfig
# or
ip addr show
```

**Check pod networking:**
```bash
# Show pod IP
hostname -i

# Ping other pods (get IPs from kubectl get pods -o wide)
ping <other-pod-ip>

# Check routing
ip route show
```

**Check pod identity:**
```bash
hostname
whoami
ps aux
```

### Step 7: Port Forwarding

**Forward pod port to localhost:**
```bash
# Forward from localhost:8085 to pod port 80
kubectl port-forward pod/$POD 8085:80
```

**Test the connection:**
- Open browser: http://127.0.0.1:8085
- You should see the nginx welcome page
- Keep the terminal open for forwarding

**Alternative: Forward to all deployment pods:**
```bash
# This forwards to any pod matching the label
kubectl port-forward deployment/firstdeployment 8085:80
```

### Step 8: Deployment Management

**Check deployment rollout status:**
```bash
kubectl rollout status deployment/firstdeployment
```

**View deployment history:**
```bash
kubectl rollout history deployment/firstdeployment
```

**Update deployment (rolling update):**
```bash
kubectl set image deployment/firstdeployment nginx=nginx:alpine
kubectl rollout status deployment/firstdeployment
```

**Rollback if needed:**
```bash
kubectl rollout undo deployment/firstdeployment
```

### Step 9: Cleanup

**Delete the deployment:**
```bash
kubectl delete deployment firstdeployment
kubectl delete -f deployment.yaml
```

**Verify cleanup:**
```bash
kubectl get deployments
kubectl get pods
```

## Key Concepts Learned

✅ **Deployment vs Pod:** Deployments manage ReplicaSets which manage Pods
✅ **Self-healing:** Kubernetes automatically recreates pods to maintain desired state
✅ **Scaling:** Horizontal scaling with replica changes
✅ **Pod networking:** Each pod gets unique IP, can communicate across nodes
✅ **Port forwarding:** Access pod services from localhost
✅ **Rolling updates:** Zero-downtime updates with rollback capability

## Next Steps

- [ConfigMap Lab](../K8s-Configmap.md) - Inject configuration
- [Secret Lab](../K8s-Secret.md) - Handle sensitive data
- [Service Lab](../K8s-Service-App.md) - Load balancing and discovery

