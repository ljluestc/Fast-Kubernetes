# Fast Kubernetes — Agent Guide

## Project Overview
**Fast Kubernetes** is a comprehensive educational resource and documentation repository for learning and mastering Kubernetes. It contains detailed guides, labs, and scripts for setting up and managing K8s clusters.

## Structure
- **Guides**: Markdown files (`K8s-*.md`) covering Pods, Deployments, Services, Ingress, etc.
- **Labs**: `labs/` directory containing practical exercises.
- **Scripts**: 
  - `create_real_cluster/`: Scripts for setting up real clusters.
  - `test-cluster.sh`: Utility to validating cluster state.
- **Quickstarts**: `QUICKSTART.md`, `Local-Testing-Guide.md`.

## Content Highlights
- **Core Concepts**: Pods, Services, Deployments, ConfigMaps.
- **Advanced**: Helm, Monitoring (Prometheus/Grafana), GitOps.
- **Cheatsheets**: `KubernetesCommandCheatSheet.md`, `HelmCheatsheet.md`.

## Usage
- This is primarily a **documentation** repo.
- **Testing**: `test-cluster.sh` can be used to verify a running cluster against the expected configurations.
- **Validation**: Ensure all YAML examples in `labs/` are valid Kubernetes manifests.

## Development Conventions
- **Format**: Clear, structured Markdown.
- **Accuracy**: Code snippets must be executable against a standard K8s cluster (minikube/kind).
- **Style**: Educational tone, problem-solution format.
