# Local K8s Infrastructure

ArgoCD configuration for a local Kubernetes cluster. Pair with [`local-k8s-apps`](https://github.com/mvs5465/local-k8s-apps) for application definitions.

## Quick Start

### Prerequisites

```bash
brew install colima docker kubectl
colima start --kubernetes --cpu 4 --memory 8 --mount /tmp/files:/tmp/files --mount ~/outline:w --mount ~/.secrets:/mnt/secrets:ro
```

### Install

```bash
cd ~/projects/local-k8s-argocd
chmod +x quick-start.sh
./quick-start.sh
```

The script installs ArgoCD and points it to the apps repo.

## Access Services

1. **Start port-forward** (requires sudo):
   ```bash
   sudo kubectl port-forward -n ingress-nginx svc/nginx-ingress-ingress-nginx-controller 80:80 443:443
   ```

2. **Add to `/etc/hosts`**:
   ```
   127.0.0.1 *.lan
   ```

3. **Visit**: http://homepage.lan

## Architecture

```
local-k8s-argocd/
├── ArgoCD (Helm installation)
├── AppProject
├── Root Applications
│   ├── argocd-app
│   └── apps-app → [local-k8s-apps]
└── Nginx Ingress Controller
```

See `CLAUDE.md` for development notes.
