# LAB: Kubernetes Rollout & Rollback

## Zero-Downtime Updates · Rolling Updates · Version Control · Pausing/Resuming

---

## Overview

This lab demonstrates **Deployment rollout and rollback** in Kubernetes:

You will learn how to:

* Perform **rolling updates** (zero-downtime)
* Use **recreate strategy** (all-at-once updates)
* **Record deployment revisions** for rollback
* **Rollback to previous versions**
* **Pause and resume** rollouts
* Monitor rollout **progress and status**

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

## Step 1: Create Recreate Strategy Deployment

Create a deployment with **recreate strategy**:

```bash
cat <<'EOF' > recreate-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: rcdeployment
  labels:
    team: development
spec:
  replicas: 5
  selector:
    matchLabels:
      app: recreate
  strategy:
    type: Recreate  # Delete ALL pods first, then create new ones
  template:
    metadata:
      labels:
        app: recreate
    spec:
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
EOF
```

Apply and verify:

```bash
kubectl apply -f recreate-deployment.yaml
kubectl get deployments
kubectl get pods -l app=recreate
```

Expected: **5 Pods running**

---

## Step 2: Create Rolling Update Deployment

Create a deployment with **rolling update strategy**:

```bash
cat <<'EOF' > rolling-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: rolldeployment
  labels:
    team: development
spec:
  replicas: 10
  selector:
    matchLabels:
      app: rolling
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 2  # Max pods unavailable during update
      maxSurge: 2        # Max extra pods during update
  template:
    metadata:
      labels:
        app: rolling
    spec:
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
EOF
```

Apply and verify:

```bash
kubectl apply -f rolling-deployment.yaml
kubectl get deployments
kubectl get pods -l app=rolling
```

Expected: **10 Pods running**

---

## Step 3: Watch Live Updates

Monitor pods and replica sets:

```bash
# Watch pods (in another terminal)
kubectl get pods -l app=rolling -w

# Watch replica sets (in another terminal)
kubectl get rs -w
```

---

## Step 4: Rolling Update (Imperative)

Update the rolling deployment image:

```bash
kubectl set image deployment rolldeployment nginx=httpd --record
```

Watch the rollout:

```bash
kubectl rollout status deployment rolldeployment -w
```

Expected:
- New pods with `httpd` image are created
- Old pods are terminated gradually
- Zero downtime during transition

---

## Step 5: View Rollout History

Check deployment history:

```bash
kubectl rollout history deployment rolldeployment
```

Expected output shows revisions with `--record` annotations.

---

## Step 6: Describe a Specific Revision

```bash
kubectl rollout history deployment rolldeployment --revision=1
kubectl rollout history deployment rolldeployment --revision=2
```

---

## Step 7: Rollback to Previous Version

Rollback to revision 1:

```bash
kubectl rollout undo deployment rolldeployment --to-revision=1
```

Watch the rollback:

```bash
kubectl rollout status deployment rolldeployment -w
```

Expected:
- Deployment returns to nginx image
- Smooth transition back

---

## Step 8: Rolling Update (Declarative)

Edit the deployment directly:

```bash
kubectl edit deployment rolldeployment --record
```

In the editor:
- Change `image: nginx` to `image: nginx:alpine`
- Save and exit

Watch the update:

```bash
kubectl rollout status deployment rolldeployment -w
```

---

## Step 9: Pause & Resume Rollout

During an update, you can pause:

```bash
kubectl rollout pause deployment rolldeployment
```

Check status:

```bash
kubectl rollout status deployment rolldeployment
```

Resume when ready:

```bash
kubectl rollout resume deployment rolldeployment
```

---

## Step 10: Cleanup

Delete both deployments:

```bash
kubectl delete deployment rcdeployment rolldeployment
kubectl delete -f recreate-deployment.yaml -f rolling-deployment.yaml
```

Verify:

```bash
kubectl get deployments
kubectl get pods
```

---

## Strategy Comparison

| Strategy | Downtime | Speed | Resource Usage |
|----------|----------|-------|----------------|
| Recreate | High | Fast | Low |
| RollingUpdate | None | Gradual | Higher |

### Recreate Strategy
- **Pros:** Simple, fast, uses fewer resources
- **Cons:** Service downtime, all pods unavailable
- **Use case:** Non-production, batch jobs

### RollingUpdate Strategy
- **Pros:** Zero downtime, gradual rollout
- **Cons:** Slower, uses more resources
- **Use case:** Production applications

---

## Key Takeaways (Interview-Level)

| Concept | Demonstrated |
|---------|-------------|
| Rolling updates | Zero-downtime deployments |
| Revision history | Version control for deployments |
| Rollback | Safe reversion to previous versions |
| Pause/Resume | Control over deployment process |
| Strategy types | Recreate vs RollingUpdate |

---

## Production Best Practices

* **Always use `--record`** for revision tracking
* **Test rollouts** in staging environments
* **Monitor resources** during updates (`kubectl top`)
* **Set appropriate** `maxUnavailable` and `maxSurge`
* **Use readiness probes** to ensure pod health
* **Plan rollback strategy** before production updates

---

## Common Issues & Solutions

### Rollout Stuck
```bash
# Check status
kubectl rollout status deployment/myapp

# Describe deployment
kubectl describe deployment myapp

# Check pod events
kubectl describe pods -l app=myapp
```

### Image Pull Errors
```bash
# Check image exists
kubectl describe pod <pod-name>

# Force rollout restart
kubectl rollout restart deployment/myapp
```

### Resource Constraints
```bash
# Check node resources
kubectl top nodes

# Scale down temporarily
kubectl scale deployment/myapp --replicas=0
```

---

## Next Recommended Labs

1. **ConfigMaps & Secrets** - Inject configuration
2. **Services** - Load balancing and discovery
3. **Ingress** - External access and routing
4. **Persistent Volumes** - Data persistence
5. **Horizontal Pod Autoscaler** - Auto-scaling
