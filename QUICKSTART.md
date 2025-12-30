# Fast-Kubernetes Quick Start Guide

## 🚀 5-Minute Cluster Setup

### 1. Install Tools
```bash
brew install kubectl multipass
```

### 2. Create Cluster
```bash
# Control plane
multipass launch --name k8s-control-plane --cpus 2 --memory 2G --disk 5G 22.04

# Worker node
multipass launch --name k8s-worker-node --cpus 2 --memory 2G --disk 5G 22.04
```

### 3. Setup Kubernetes
```bash
# On control plane
multipass shell k8s-control-plane
wget https://raw.githubusercontent.com/yukinakanaka/kubernetes-on-apple-silicon-with-multipass/main/setup.sh
chmod +x setup.sh && ./setup.sh
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

# Configure kubectl
mkdir -p $HOME/.kube
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Install CNI
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

# Get join command
kubeadm token create --print-join-command
```

### 4. Join Worker
```bash
# On worker node
multipass shell k8s-worker-node
wget https://raw.githubusercontent.com/yukinakanaka/kubernetes-on-apple-silicon-with-multipass/main/setup.sh
chmod +x setup.sh && ./setup.sh
# Paste join command from step 3
```

### 5. Configure kubectl on Mac
```bash
# Copy config
multipass transfer k8s-control-plane:/home/ubuntu/.kube/config ~/.kube/multipass-admin.conf

# Set permanently
echo 'export KUBECONFIG=~/.kube/multipass-admin.conf' >> ~/.zshrc
source ~/.zshrc

# Test
kubectl get nodes
```

## 🧪 Quick Test Commands

### Basic Testing
```bash
# Health check
kubectl get nodes
kubectl get pods -A

# Test pod
kubectl run test-pod --image=nginx --restart=Never
kubectl get pods -o wide
kubectl delete pod test-pod
```

### Multi-Container Testing
```bash
kubectl apply -f labs/pod/multicontainer.yaml
kubectl port-forward pod/multicontainer 8080:80
# Open http://127.0.0.1:8080 in browser
```

### CrashLoopBackOff Demo
```bash
kubectl run crash-test --image=busybox --restart=Always --command -- sh -c "echo CRASHING; sleep 1; exit 1"
kubectl get pods  # Shows CrashLoopBackOff
kubectl logs crash-test --previous
kubectl delete pod crash-test
```

## 🔧 Troubleshooting Quick Reference

### kubectl Connection Issues
```bash
# If you see "localhost:8080 was refused"
export KUBECONFIG=~/.kube/multipass-admin.conf
kubectl get nodes
```

### VM Networking Issues
```bash
# If SSH timeouts to VMs
multipass stop k8s-control-plane
multipass start k8s-control-plane
multipass shell k8s-control-plane
```

### Automated Testing
```bash
# Run comprehensive test
./test-cluster.sh
```

## 📁 Available Labs
- `K8s-CreatingPod-Imperative.md` - Basic pod operations
- `K8s-CreatingPod-Declarative.md` - YAML pod creation
- `K8s-Multicontainer-Sidecar.md` - Multi-container patterns
- `Local-Testing-Guide.md` - Complete testing guide
- `labs/pod/` - Sample YAML files

## 🧹 Cleanup
```bash
# Stop VMs
multipass stop k8s-control-plane k8s-worker-node

# Delete completely
multipass delete k8s-control-plane k8s-worker-node --purge
```

## 📚 Full Documentation
See `README.md` and `Local-Testing-Guide.md` for complete instructions.
