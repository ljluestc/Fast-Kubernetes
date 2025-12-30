# LAB: Kubernetes Deployment

## Scale Up / Scale Down · Exec (bash/sh) · Pod Networking · Port-Forwarding

---

## Overview

This lab demonstrates **Deployment fundamentals** in Kubernetes:

You will learn how to:

* Create a **Deployment**
* Understand how a Deployment manages Pods (desired state)
* Scale replicas **up and down**
* Observe **self-healing** when Pods are deleted
* Exec into a Pod and inspect networking
* Ping other Pods in the same cluster
* Access a Pod using **kubectl port-forward**

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

## Step 1: Create the Deployment Manifest

Create a file named `deployment.yaml`:

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

Verify file exists:

```bash
ls -l deployment.yaml
```

---

## Step 2: Create the Deployment

```bash
kubectl apply -f deployment.yaml
```

Verify deployment:

```bash
kubectl get deployments
```

Expected:

```
NAME              READY   UP-TO-DATE   AVAILABLE
firstdeployment   3/3     3            3
```

---

## Step 3: List Pods Created by the Deployment

```bash
kubectl get pods -l app=frontend
```

You should see **3 Pods**.

---

## Step 4: Describe the Deployment (Important)

```bash
kubectl describe deployment firstdeployment
```

Key things to observe:

* Replica count
* Pod template
* Selector
* Events

This explains **how Deployments enforce desired state**.

---

## Step 5: Self-Healing Demo (Delete a Pod)

Delete **one Pod manually**:

```bash
kubectl delete pod $(kubectl get pods -l app=frontend -o jsonpath='{.items[0].metadata.name}')
```

Immediately list Pods again:

```bash
kubectl get pods -l app=frontend
```

✅ You will still see **3 Pods**
👉 Deployment automatically created a replacement.

---

## Step 6: Scale Up the Deployment

Scale from 3 → 5 replicas:

```bash
kubectl scale deployment firstdeployment --replicas=5
```

Verify:

```bash
kubectl get deployment firstdeployment
kubectl get pods -l app=frontend
```

Expected:

```
READY 5/5
```

---

## Step 7: Scale Down the Deployment

Scale back to 3 replicas:

```bash
kubectl scale deployment firstdeployment --replicas=3
```

Verify:

```bash
kubectl get pods -l app=frontend
```

---

## Step 8: Show Pod IPs and Nodes

```bash
kubectl get pods -l app=frontend -o wide
```

Example output:

```
NAME                        IP            NODE
firstdeployment-xxxxx       10.244.1.8    k8s-worker-node
firstdeployment-yyyyy       10.244.1.9    k8s-worker-node
firstdeployment-zzzzz       10.244.1.10   k8s-worker-node
```

This shows:

* Each Pod has a **unique IP**
* All Pods are routable within the cluster

---

## Step 9: Exec Into a Pod (Shell Access)

Pick one Pod:

```bash
POD=$(kubectl get pods -l app=frontend -o jsonpath='{.items[0].metadata.name}')
kubectl exec -it $POD -- sh
```

> ⚠️ nginx uses `sh`, not `bash`

---

## Step 10: Install Networking Tools (Inside Pod)

Inside the container:

```sh
apt update
apt install -y iputils-ping net-tools
```

---

## Step 11: Show Network Interfaces

```sh
ifconfig
```

You will see:

* `eth0` with a **Pod IP**
* Loopback interface

---

## Step 12: Ping Other Pods

From inside the container:

```sh
ping 10.244.1.9
ping 10.244.1.10
```

(Use IPs from `kubectl get pods -o wide`)

✅ Successful pings prove:

* Pod-to-Pod networking
* CNI (Flannel) is working

Exit container:

```sh
exit
```

---

## Step 13: Port-Forward One Pod

Forward Pod port `80` to local macOS port `8085`:

```bash
kubectl port-forward pod/$POD 8085:80
```

Expected:

```
Forwarding from 127.0.0.1:8085 -> 80
```

---

## Step 14: Access from Browser

Open on your Mac:

```
http://127.0.0.1:8085
```

You should see the **nginx welcome page**.

> Note: Port-forward connects to **one Pod only**, not load-balanced.

---

## Step 15: Cleanup

Delete the Deployment:

```bash
kubectl delete deployment firstdeployment
```

Verify:

```bash
kubectl get deployments
kubectl get pods
```

---

## Key Takeaways (Interview-Level)

| Concept        | Demonstrated             |
| -------------- | ------------------------ |
| Deployment     | Declarative workload     |
| ReplicaSet     | Ensures desired replicas |
| Self-healing   | Pod recreation           |
| Scaling        | Horizontal scaling       |
| Pod networking | Unique IPs               |
| Exec debugging | Shell access             |
| Port-forward   | Local debugging          |

---

## Notes

* Deployments manage **ReplicaSets**, not Pods directly
* Pod IPs are **ephemeral**
* `kubectl port-forward` is **debug-only**
* Production traffic should use:

  * Service
  * Ingress
  * LoadBalancer

---

## Next Recommended Labs

1. Deployment Rolling Update & Rollback
2. Deployment + Service (ClusterIP / NodePort)
3. Load balancing across replicas
4. Readiness & Liveness Probes
5. HPA (Horizontal Pod Autoscaler)

