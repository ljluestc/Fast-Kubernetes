## LAB: K8s Creating Pod - Declarative Way (With Yaml File)

This scenario shows:
- how to create basic K8s pod using yaml file,
- how to get more information about pod (to solve troubleshooting),

### Prerequisites

#### For Minikube Clusters:
- Start minikube: `minikube start`

#### For Multipass/Kubeadm Clusters:
- Ensure your cluster is running: `multipass list`
- Set kubectl config: `export KUBECONFIG=~/.kube/multipass-admin.conf`
- Verify connection: `kubectl get nodes`

### Steps
  
- Create Yaml file (pod1.yaml) in your directory and copy the below definition into the file:
- File: https://github.com/omerbsezer/Fast-Kubernetes/blob/main/labs/pod/pod1.yaml 

```
apiVersion: v1      
kind: Pod                         # type of K8s object: Pod
metadata:
  name: firstpod                  # name of pod
  labels:
    app: frontend                 # label pod with "app:frontend"   
spec:
  containers: 
  - name: nginx                   
    image: nginx:latest           # image name:image version, nginx downloads from DockerHub
    ports:
    - containerPort: 80           # open ports in the container
    env:                          # environment variables
      - name: USER
        value: "username"
```

![image](https://user-images.githubusercontent.com/10358317/153674646-8997eb99-12b9-4394-91f2-2de4032ee3db.png)


 - Apply/run the file to create pod in declarative way:
   ```bash
   kubectl apply -f pod1.yaml
   kubectl get pods -o wide
   ```

   ![image](https://user-images.githubusercontent.com/10358317/153198471-55d92940-1141-4e04-a701-6356daaf0181.png)
  
- Describe firstpod ("kubectl describe pods firstpod"):

  ![image](https://user-images.githubusercontent.com/10358317/153199893-95bfbef0-61b4-4c41-bd89-481d976c272c.png)

- Delete pod and get all pods in the default namepace  ("kubectl delete -f pod1.yaml"):

  ![image](https://user-images.githubusercontent.com/10358317/153200081-3f7823a8-e5d0-4143-aac4-157948fe2a61.png)
  
### Cleanup

To delete the pod:
```bash
kubectl delete -f pod1.yaml
```

To stop clusters:
- **Minikube:** `minikube delete`
- **Multipass:** `multipass stop k8s-control-plane k8s-worker-node`

