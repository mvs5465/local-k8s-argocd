# Local K8s + ArgoCD Setup

A learning project to set up a local Kubernetes cluster on your laptop with ArgoCD for continuous deployment.

## Architecture

- **K8s Cluster**: Docker Desktop (macOS) or minikube/kind
- **ArgoCD**: GitOps operator for declarative deployments
- **Access**: ArgoCD UI via `localhost:8080`

## Quick Start

```bash
# 1. Start K8s cluster
# 2. Install ArgoCD
# 3. Port-forward ArgoCD UI
# 4. Log in and explore
```

## Project Structure

- `setup/` - Installation scripts and docs
- `manifests/` - Kubernetes manifests (apps to deploy via ArgoCD)
- `docs/` - Learning notes and references
