# AGENTS.md - Fast Kubernetes Project

This file provides guidance to AI agents working on the Fast Kubernetes project.

## Project Overview

Fast Kubernetes is a comprehensive Kubernetes learning and training resource. It provides:

- **Content Type**: Documentation and tutorials
- **Focus**: Kubernetes concepts, commands, and practical examples
- **Format**: Markdown documentation with code examples
- **Audience**: Developers, DevOps engineers, and system administrators learning Kubernetes

## Key Files and Directories

- `README.md` - Main project documentation and overview
- `QUICKSTART.md` - Quick start guide for beginners
- `Local-Testing-Guide.md` - Guide for local Kubernetes testing
- `K8s-*.md` files - Individual Kubernetes concept tutorials
- `labs/` - Practical lab exercises
- `create_real_cluster/` - Cluster creation scripts
- `test-cluster.sh` - Cluster testing script

## Project Structure

```
.
├── README.md                      # Main documentation
├── QUICKSTART.md                  # Quick start guide
├── Local-Testing-Guide.md         # Local testing instructions
├── K8s-*.md                       # Individual Kubernetes topics
├── Helm.md                        # Helm package manager guide
├── HelmCheatsheet.md              # Helm cheat sheet
├── KubernetesCommandCheatSheet.md  # Kubernetes command reference
├── labs/                          # Practical exercises
├── create_real_cluster/           # Cluster setup scripts
└── test-cluster.sh                # Cluster testing utility
```

## Content Organization

### Core Kubernetes Concepts
- **Pods**: Creating and managing pods (imperative and declarative)
- **Deployments**: Managing application deployments
- **Services**: Exposing applications with services
- **ConfigMaps & Secrets**: Configuration management
- **Volumes**: Persistent storage
- **Jobs & CronJobs**: Batch processing
- **DaemonSets**: System daemons
- **StatefulSets**: Stateful applications
- **Ingress**: HTTP routing

### Advanced Topics
- **Monitoring**: Prometheus and Grafana setup
- **Helm**: Package management
- **Multi-container Pods**: Sidecar patterns
- **Node Affinity**: Pod scheduling control
- **Taints & Tolerations**: Node restrictions
- **Rollouts & Rollbacks**: Deployment strategies

### Practical Resources
- **Cheat Sheets**: Quick command references
- **Labs**: Hands-on exercises
- **Cluster Setup**: Real cluster creation guides

## Documentation Standards

- **Format**: Markdown (.md files)
- **Style**: Clear, concise, and practical
- **Structure**: Problem -> Solution -> Example pattern
- **Code Blocks**: Use proper syntax highlighting
- **Examples**: Include real-world scenarios
- **Cross-references**: Link related topics

## Writing Guidelines

- **Audience**: Assume intermediate technical knowledge
- **Tone**: Professional yet approachable
- **Examples**: Use realistic scenarios
- **Commands**: Show full commands with explanations
- **Output**: Include expected output when helpful
- **Troubleshooting**: Add common issues and solutions

## Testing and Validation

- **Cluster Testing**: Use `test-cluster.sh` to validate cluster setup
- **Command Validation**: Test all documented commands
- **Example Verification**: Verify all code examples work
- **Cross-platform**: Ensure examples work on major platforms

## Contribution Process

1. **Identify Gap**: Find missing or outdated content
2. **Research**: Ensure accuracy of new content
3. **Write**: Create clear, well-structured documentation
4. **Test**: Validate all examples and commands
5. **Review**: Get feedback from maintainers
6. **Update**: Keep content current with Kubernetes versions

## Versioning and Updates

- **Kubernetes Versions**: Document which versions examples target
- **Deprecation**: Note deprecated features and alternatives
- **Changelog**: Track major updates to documentation
- **Compatibility**: Test with current Kubernetes releases

## Learning Path

### Beginner Path
1. Start with `QUICKSTART.md`
2. Read core concept documents (Pods, Deployments, Services)
3. Try basic labs
4. Use cheat sheets for reference

### Intermediate Path
1. Advanced topics (StatefulSets, Ingress, ConfigMaps)
2. Helm package management
3. Monitoring setup
4. Multi-container patterns

### Advanced Path
1. Cluster setup and management
2. Production deployment strategies
3. Troubleshooting guides
4. Performance optimization

## Security Considerations

- **Cluster Access**: Document secure access patterns
- **Secrets Management**: Best practices for sensitive data
- **Network Policies**: Secure communication examples
- **RBAC**: Role-based access control guides
- **Updates**: Emphasize keeping clusters updated

## Deployment Considerations

While this is primarily a documentation project:
- **Examples**: Should work in common environments (Minikube, Kind, real clusters)
- **Portability**: Avoid environment-specific assumptions
- **Cleanup**: Document how to clean up resources
- **Cost**: Warn about potential costs for cloud resources

## Git Conventions

- **Branching**: Use feature branches for new content
- **Commits**: Clear, descriptive commit messages
- **Pull Requests**: Include context and purpose
- **Reviews**: Be open to feedback and improvements
- **Updates**: Regularly review and update content

## CI/CD Considerations

For a documentation project:
- **Link Validation**: Automated checking of external links
- **Markdown Linting**: Consistent formatting
- **Spell Checking**: Catch typos and errors
- **Build Validation**: Ensure all examples are syntactically correct
