## LAB: K8s Creating Pod - Imperative Way

This scenario shows:
- how to create basic K8s pod using imperative commands,
- how to get more information about pod (to solve troubleshooting),
- how to run commands in pod,
- how to delete pod.

### Prerequisites

#### For Minikube Clusters:
- Start minikube: `minikube start`
- Verify kubectl context: `kubectl config current-context`

#### For Multipass/Kubeadm Clusters:
- Ensure your cluster is running: `multipass list`
- Set kubectl config to point to your cluster:
  ```bash
  export KUBECONFIG=~/.kube/multipass-admin.conf
  # Or add to your shell profile:
  echo 'export KUBECONFIG=~/.kube/multipass-admin.conf' >> ~/.zshrc
  source ~/.zshrc
  ```
- Verify connection: `kubectl get nodes`

**Note:** If you see connection errors like "The connection to the server localhost:8080 was refused", you need to set the correct KUBECONFIG path for your multipass cluster.

### Steps

- Run pod in imperative way
  - `kubectl run podName --image=imageName`
  - `kubectl get pods -o wide` : get info about pods

  For multipass clusters, ensure KUBECONFIG is set:
  ```bash
  export KUBECONFIG=~/.kube/multipass-admin.conf
  kubectl run test-nginx --image=nginx --restart=Never
  kubectl get pods -o wide
  ```

  ![image](https://user-images.githubusercontent.com/10358317/153183932-f8cd1547-3b10-47af-be3a-a1aedbfcf4ad.png)

- Describe pod to get mor information about pods (when encountered troubleshooting):
  
  ![image](https://user-images.githubusercontent.com/10358317/153184743-b0617841-db71-4c02-8d7b-c0054d9249bd.png)
  
- To reach logs in the pod (when encountered troubleshooting):
  
  ![image](https://user-images.githubusercontent.com/10358317/153185140-e7c2a4e3-29d0-4636-9586-62eec358c6bb.png)

- To reach logs in the pod 2ith "-f" (LIVE Logs, attach to the pod's log):
  
  ![image](https://user-images.githubusercontent.com/10358317/153185353-1969fe8c-e166-492e-b55d-2d96cedf3709.png)
  
 - Run command on pod ("kubectl exec **podName** -- **command**"):
  
   ![image](https://user-images.githubusercontent.com/10358317/153185867-fbe27ddb-619d-4d3e-bbce-3f021c073ad8.png)
  
  - Entering into the pod and running bash or sh on pod:
    - "kubectl exec -it **podName** -- bash"
    - "kubectl exec -it **podName** -- /bins/sh"
    - exit from pods 2 ways:
      - "exit" command
      - "CTRL+P+Q"
 
    ![image](https://user-images.githubusercontent.com/10358317/153186349-4dff117c-66ca-46a9-8030-2bdf27e6e0bb.png)
  
- Delete pod:

  ```bash
  kubectl delete pod podName
  # Or delete all pods with a specific label
  kubectl delete pods -l app=myapp
  ```

  ![image](https://user-images.githubusercontent.com/10358317/153187052-d3b12b0d-85cb-4885-afa9-9a7904dc964b.png)

### Troubleshooting

#### Connection Refused Errors
If you see errors like:
```
The connection to the server localhost:8080 was refused - did you specify the right host or port?
```

**Solution for Multipass Clusters:**
1. Ensure your multipass VMs are running: `multipass list`
2. Set the correct kubeconfig:
   ```bash
   export KUBECONFIG=~/.kube/multipass-admin.conf
   ```
3. Test connection: `kubectl get nodes`
4. Make it permanent by adding to your shell profile

**Solution for Minikube:**
1. Start minikube: `minikube start`
2. Verify kubectl context: `kubectl config current-context`

#### Pod Issues
- **Pod not starting:** Check pod status with `kubectl describe pod podName`
- **Image pull errors:** Verify image name and registry access
- **Resource constraints:** Check if cluster has enough CPU/memory

### Best Practices

- Use `--restart=Never` for testing pods to prevent automatic restarts
- Always check pod logs with `kubectl logs podName` for debugging
- Use labels for better pod management: `kubectl run mypod --image=nginx --labels="app=web,env=test"`

### Next Steps

The imperative way could be difficult to store and manage processes. Every time you have to enter commands manually. To prevent this, we can use YAML files to define pods and their features. This approach is called the **Declarative Way**.

**Go to Declarative Way:** [LAB: K8s Creating Pod - Declarative Way](K8-CreatingPod-Declerative.md)
