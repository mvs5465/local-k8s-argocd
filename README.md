# Local Kubernetes Cluster

A local K8s cluster with ArgoCD, Prometheus, and Grafana.

<!-- Test commit status indicator -->

## Setup

### Prerequisites

```bash
brew install colima docker kubectl
colima start --kubernetes
```

### Installation

```bash
cd ~/projects/local-k8s-argocd
chmod +x quick-start.sh
./quick-start.sh
```

This installs ArgoCD in the cluster and outputs the initial admin password.

### Access Services

| Service | URL | Port |
|---------|-----|------|
| Dashboard | http://localhost:8888 | 8888 |
| Docs | http://localhost:7777 | 7777 |
| ArgoCD | https://localhost:8080 | 8080 |
| Grafana | http://localhost:3000 | 3000 |
| Prometheus | http://localhost:9090 | 9090 |

## Components

**ArgoCD** (https://localhost:8080)
- GitOps deployments
- Syncs git repos to cluster
- No auth required

**Grafana** (http://localhost:3000)
- Visualize metrics
- Pre-built Kubernetes dashboards
- No auth required

**Prometheus** (http://localhost:9090)
- Metrics collection
- Scrapes K8s API, nodes, pods
- 7-day retention

**Dashboard** (http://localhost:8888)
- Links to all services

**Docs** (http://localhost:7777)
- Setup guides and documentation

## Port-Forwarding

If port-forwards close, restart them:

```bash
kubectl port-forward -n default svc/dashboard-ui 8888:80 &
kubectl port-forward -n default svc/docs-server 7777:80 &
kubectl port-forward -n argocd svc/argocd-server 8080:443 &
kubectl port-forward -n monitoring svc/grafana 3000:80 &
kubectl port-forward -n monitoring svc/prometheus-server 9090:80 &
```

## Deploying Applications

Create a git repo with Kubernetes manifests:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: app
        image: my-image:latest
```

In ArgoCD UI:
1. Click "+ New App"
2. Set repository URL to your repo
3. Set path to manifests directory
4. Click Create

ArgoCD will sync your app to the cluster and keep it in sync when you push changes to git.

## Documentation

See the docs server for detailed guides:

- GETTING_STARTED.md - Quick start
- SETUP.md - Installation details
- WORKFLOW.md - GitOps workflow
- MONITORING_SETUP.md - Prometheus/Grafana setup
- DASHBOARDS.md - Grafana usage
- ARCHITECTURE.md - System design

## Troubleshooting

Check cluster status:
```bash
kubectl get nodes
kubectl get pods -A
```

View ArgoCD logs:
```bash
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-server
```

Restart Colima:
```bash
colima stop && colima start --kubernetes
```

## Project Structure

```
manifests/
├── grafana-app.yaml
├── prometheus-app.yaml
├── dashboard-ui.yaml
└── docs-server.yaml

quick-start.sh
docs/
└── ARCHITECTURE.md

README.md and documentation files
```

All applications are deployed as ArgoCD Applications using Helm charts.
