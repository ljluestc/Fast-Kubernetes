# AGENTS.md
 
 ## Project overview
 Fast-Kubernetes is a documentation-first repository: it contains Markdown guides, hands-on labs, and scripts related to Kubernetes.
 
 The repo does not have a conventional “build” step; the primary output is documentation and runnable examples.
 
 ## Key files and directories
 - `README.md`: main documentation (includes a large table of contents and links)
 - `QUICKSTART.md`: quickstart
 - `Local-Testing-Guide.md`: local testing guide
 - `K8s-*.md`: topic guides and labs (Pods, Deployments, Services, etc.)
 - `labs/`: hands-on exercise material
 - `create_real_cluster/`: cluster creation resources
 - `test-cluster.sh`: kubectl-based smoke test for a running cluster
 - `KubernetesCommandCheatSheet.md`, `HelmCheatsheet.md`: command references
 
 ## Technology stack
 - Markdown documentation
 - Shell scripting (`test-cluster.sh`)
 - Kubernetes tooling is assumed for running examples: `kubectl` and access to a cluster
 
 ## How the repo is organized
 - Most guides are written as self-contained Markdown files.
 - The `README.md` links to guides and labs rather than duplicating everything.
 - The `labs/` directory contains practical examples; verify them with a real cluster.
 
 ## Validation and testing
 
 ### Smoke test a cluster
 `test-cluster.sh` validates that:
 - `kubectl` is configured (`kubectl cluster-info`)
 - nodes exist and are Ready
 - a simple BusyBox pod can be created and executed
 - Flannel CNI pods are healthy (if `kube-flannel` namespace exists)
 
 Run:
 - `./test-cluster.sh`
 
 Notes:
 - The script expects `kubectl` to work against your target cluster.
 - It suggests setting `KUBECONFIG=~/.kube/multipass-admin.conf` for the Multipass guide.
 
 ### Documentation correctness
 When editing docs:
 - Ensure kubectl commands match current Kubernetes behavior.
 - Prefer copy/pastable commands.
 - If you add YAML manifests, validate them with `kubectl apply --dry-run=client -f <file>` (when feasible).
 
 ## Writing / contribution conventions
 - Keep an educational tone consistent with the existing docs.
 - Prefer “concept → command/example → expected result/troubleshooting”.
 - Avoid environment-specific assumptions unless the guide is explicitly for that environment.
 
 ## Security considerations
 - When documenting cluster setup, avoid encouraging insecure defaults (e.g., overly permissive RBAC) without clearly labeling them as unsafe.
 - Remind readers to clean up resources created by labs to avoid unexpected cloud costs.

## Task Implementation
1. **Analyze Requirements**: Refer to `README.md` for detailed feature specifications and system design.
2. **Implementation**: Modify source code in the respective directories (e.g., `src/`, `internal/`).
3. **Verification**: Run provided build and test commands (see above) to ensure correctness.
4. **Push Changes**:
   - Commit changes: `git commit -m "feat: implement <feature>"`
   - Push to remote: `git push origin <branch-name>`
