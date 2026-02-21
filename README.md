# Local K8s Infrastructure

ArgoCD configuration for a local Kubernetes cluster. Pair with [`local-k8s-apps`](https://github.com/mvs5465/local-k8s-apps) for application definitions.

## Quick Start

### Prerequisites

```bash
brew install colima docker kubectl
colima start --kubernetes --cpu 4 --memory 4
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
   127.0.0.1 argocd.lan grafana.lan prometheus.lan gatus.lan homepage.lan jellyfin.lan
   ```

3. **Visit**:
   - Homepage: http://homepage.lan (main dashboard with links to all services)
   - ArgoCD: https://argocd.lan
   - Grafana: http://grafana.lan
   - Prometheus: http://prometheus.lan
   - Gatus: http://gatus.lan (uptime monitoring)
   - Jellyfin: http://jellyfin.lan (media server)

## Architecture

- **Two-repo design**: Infrastructure (this repo, stable) + Applications (companion repo, active)
- **ArgoCD**: Helm-installed with fast 10s reconciliation
- **App-of-apps**: Parent apps discover children automatically
- **Ingress**: Nginx controller routing to all services

## What's Inside

- ArgoCD installation + configuration
- AppProject + root applications pointing to `local-k8s-apps`
- Nginx Ingress Controller
- GitHub token authentication for faster polling

See `CLAUDE.md` for development notes.
