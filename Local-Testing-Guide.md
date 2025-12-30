# Local Testing Guide: Kubernetes with Multipass

This guide provides comprehensive instructions for testing Kubernetes locally using Multipass VMs, based on real-world troubleshooting and setup experiences.

## 🚀 Quick Start

### Prerequisites
- Multipass installed and working
- kubectl installed on macOS
- Basic understanding of kubectl commands

### Cluster Setup Verification
```bash
# Check VMs are running
multipass list

# Set kubectl config (CRITICAL - do this first!)
export KUBECONFIG=~/.kube/multipass-admin.conf

# Verify cluster connection
kubectl get nodes
kubectl cluster-info
```

## 🔧 Common Setup Issues & Fixes

### 1. kubectl Connection Refused (Most Common)
**Symptoms:**
```
The connection to the server localhost:8080 was refused
```

**Root Cause:** kubectl not configured for multipass cluster

**Fix:**
```bash
# Set kubeconfig
export KUBECONFIG=~/.kube/multipass-admin.conf

# Make permanent
echo 'export KUBECONFIG=~/.kube/multipass-admin.conf' >> ~/.zshrc
source ~/.zshrc

# Test
kubectl get nodes
```

### 2. Multipass VM Unreachable
**Symptoms:**
```
multipass shell k8s-control-plane
shell failed: ssh connection failed: 'Timeout connecting to 192.168.64.2'
```

**Root Cause:** VM networking wedged (common on macOS)

**Fix:**
```bash
# Hard restart VM
multipass stop k8s-control-plane
multipass start k8s-control-plane

# Wait 30 seconds, then test
multipass shell k8s-control-plane
```

## 🧪 Pod Testing Scenarios

### Basic Pod Operations
```bash
# Create test pod
kubectl run test-nginx --image=nginx --restart=Never
kubectl get pods -o wide

# Debug pod
kubectl describe pod test-nginx
kubectl logs test-nginx

# Execute commands
kubectl exec test-nginx -- ls /usr/share/nginx/html
kubectl exec -it test-nginx -- sh

# Clean up
kubectl delete pod test-nginx
```

### CrashLoopBackOff Testing
```bash
# Create failing pod
kubectl run crash-test --image=busybox --restart=Always \
  --command -- sh -c "echo CRASHING; sleep 1; exit 1"

# Observe failure
kubectl get pods  # Shows CrashLoopBackOff

# Debug properly
kubectl describe pod crash-test
kubectl logs crash-test --previous

# Clean up
kubectl delete pod crash-test
```

### Multi-Container Pod Testing
```bash
# Apply multi-container pod
kubectl apply -f multicontainer.yaml
kubectl get pods -o wide

# Verify both containers
kubectl get pod multicontainer \
  -o jsonpath='{.status.containerStatuses[*].name}'

# Test shared networking (same IP)
kubectl exec -it multicontainer -c webcontainer -- hostname -i
kubectl exec -it multicontainer -c sidecarcontainer -- hostname -i

# Test shared volume
kubectl exec -it multicontainer -c webcontainer -- ls /usr/share/nginx/html
kubectl exec -it multicontainer -c sidecarcontainer -- ls /var/log

# Monitor sidecar
kubectl logs multicontainer -c sidecarcontainer -f
```

## 🌐 Networking Testing

### Port Forwarding
```bash
# Forward pod port to localhost
kubectl port-forward pod/multicontainer 8080:80

# Test in browser: http://127.0.0.1:8080
```

### Service Testing
```bash
# Create deployment
kubectl create deployment web --image=nginx

# Expose as NodePort
kubectl expose deployment web --type=NodePort --port=80

# Get service info
kubectl get svc

# Find worker node IP
multipass info k8s-worker-node

# Access via NodePort
curl http://<WORKER-IP>:<NODEPORT>
```

## 🔍 Advanced Debugging

### Pod States & Debugging
```bash
# Check pod phases
kubectl get pods

# Detailed pod info
kubectl describe pod <pod-name>

# Container logs
kubectl logs <pod-name> [-c <container>] [--previous]

# Live logs
kubectl logs -f <pod-name>
```

### Common Pod Issues

#### ContainerCreating Stalls
```bash
kubectl describe pod <pod-name>
# Look for:
# - ImagePullBackOff
# - NetworkPluginNotReady
# - FailedMount
```

#### CrashLoopBackOff
```bash
kubectl describe pod <pod-name>
kubectl logs <pod-name> --previous
# Check exit codes and error messages
```

#### Pending Pods
```bash
kubectl describe pod <pod-name>
# Look for scheduling constraints, resource issues
```

### Cluster Health Checks
```bash
# Overall status
kubectl get nodes
kubectl get pods -A

# Control plane components
kubectl get pods -n kube-system

# Logs from system components
kubectl logs -n kube-system kube-apiserver-k8s-control-plane
kubectl logs -n kube-system etcd-k8s-control-plane
```

## 🧹 Cleanup Commands

### Remove Test Resources
```bash
# Delete all test pods
kubectl delete pods --selector app=test

# Delete specific resources
kubectl delete pod,svc,deployment --all

# Reset namespace (CAUTION)
kubectl delete all --all
```

### Multipass Management
```bash
# Stop VMs
multipass stop k8s-control-plane k8s-worker-node

# Start VMs
multipass start k8s-control-plane k8s-worker-node

# Complete reset (last resort)
multipass delete k8s-control-plane k8s-worker-node --purge
```

## 📋 Testing Checklist

### Pre-Testing Setup
- [ ] Multipass installed: `multipass version`
- [ ] kubectl installed: `kubectl version --client`
- [ ] VMs running: `multipass list`
- [ ] kubectl configured: `export KUBECONFIG=~/.kube/multipass-admin.conf`
- [ ] Cluster reachable: `kubectl get nodes`

### Basic Pod Testing
- [ ] Create pod: `kubectl run test-pod --image=nginx`
- [ ] Pod running: `kubectl get pods`
- [ ] Describe works: `kubectl describe pod test-pod`
- [ ] Logs accessible: `kubectl logs test-pod`
- [ ] Exec works: `kubectl exec -it test-pod -- echo hello`
- [ ] Delete works: `kubectl delete pod test-pod`

### Multi-Container Testing
- [ ] Apply YAML: `kubectl apply -f multicontainer.yaml`
- [ ] Both containers running
- [ ] Shared networking verified
- [ ] Shared volume verified
- [ ] Port forwarding works

### Networking Testing
- [ ] Port forwarding: `kubectl port-forward`
- [ ] Service creation: `kubectl expose`
- [ ] External access via NodePort

## 🚨 Emergency Troubleshooting

### Complete kubectl Reset
```bash
# Clear any cached config
unset KUBECONFIG
rm -f ~/.kube/config

# Re-import config
multipass transfer k8s-control-plane:/home/ubuntu/.kube/config ~/.kube/multipass-admin.conf
export KUBECONFIG=~/.kube/multipass-admin.conf
```

### Multipass Nuclear Reset
```bash
# Kill daemon
sudo pkill multipassd

# Restart app
open -a Multipass

# Wait, then restart VMs
multipass start k8s-control-plane
multipass start k8s-worker-node
```

### When All Else Fails
```bash
# Recreate entire cluster
multipass delete k8s-control-plane k8s-worker-node --purge

# Rerun setup script
# ./setup-k8s.sh on control plane
# kubeadm join on worker
```

## 📚 Reference Commands

### Status Checks
```bash
kubectl get nodes
kubectl get pods -A
kubectl get svc
kubectl cluster-info
```

### Debugging
```bash
kubectl describe <resource> <name>
kubectl logs <pod> [-c <container>] [--previous] [-f]
kubectl exec -it <pod> -- <command>
```

### Networking
```bash
kubectl port-forward <resource>/<name> <local-port>:<remote-port>
kubectl expose <resource> <name> --type=<type>
```

### Cleanup
```bash
kubectl delete <resource> <name>
kubectl delete all --all
multipass stop <vm-name>
```
