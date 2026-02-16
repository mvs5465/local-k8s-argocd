# Local Kubernetes Cluster with ArgoCD, Prometheus & Grafana

A complete local development Kubernetes cluster with GitOps, monitoring, and an interactive dashboard.

## What's Included

### 🎯 Dashboard (Entrypoint)
**http://localhost:8888** - Central hub with links to all services

### 🚀 ArgoCD
**https://localhost:8080** - GitOps continuous deployment
- Git-based application management
- Auto-sync deployments
- No login required (configured for local dev)

### 📊 Grafana
**http://localhost:3000** - Cluster metrics visualization
- 3 pre-built Kubernetes dashboards
- Real-time cluster health monitoring
- No login required (anonymous access)

### 📈 Prometheus
**http://localhost:9090** - Metrics collection
- Scrapes K8s API, nodes, pods, services
- 48,000+ time series collected
- 7-day retention, 2GB storage

### 📚 Documentation Server
**http://localhost:7777** - Interactive guides
- Getting started guide
- Setup instructions
- GitOps workflow guide
- Architecture deep dive

## Tech Stack

| Component | Technology | Version |
|-----------|-----------|---------|
| **VM** | Colima | Latest |
| **K8s** | K3s | v1.35.0 |
| **GitOps** | ArgoCD | v2.11.7 |
| **Metrics** | Prometheus | v25.3.1 |
| **Visualization** | Grafana | 11.1.0 |
| **Runtime** | Docker | Latest |

## Quick Start

### 1. Install Prerequisites

```bash
brew install colima docker kubectl
colima start --kubernetes
```

### 2. Run Setup Script

```bash
cd ~/projects/local-k8s-argocd
chmod +x quick-start.sh
./quick-start.sh
```

### 3. Access Dashboard

Open **http://localhost:8888** in your browser. All services are linked and ready to use.

### 4. Port-Forward Services (if closed)

```bash
# Dashboard
kubectl port-forward -n default svc/dashboard-ui 8888:80

# Documentation
kubectl port-forward -n default svc/docs-server 7777:80

# ArgoCD
kubectl port-forward -n argocd svc/argocd-server 8080:443

# Grafana
kubectl port-forward -n monitoring svc/grafana 3000:80

# Prometheus
kubectl port-forward -n monitoring svc/prometheus-server 9090:80
```

## Service Access

| Service | URL | Port | Namespace |
|---------|-----|------|-----------|
| **Dashboard** | http://localhost:8888 | 8888 | default |
| **Docs** | http://localhost:7777 | 7777 | default |
| **ArgoCD** | https://localhost:8080 | 8080 | argocd |
| **Grafana** | http://localhost:3000 | 3000 | monitoring |
| **Prometheus** | http://localhost:9090 | 9090 | monitoring |

## Project Structure

```
local-k8s-argocd/
├── manifests/
│   ├── grafana-app.yaml          (Grafana Helm deployment)
│   ├── prometheus-app.yaml       (Prometheus Helm deployment)
│   ├── dashboard-ui.yaml         (Dashboard home page)
│   └── docs-server.yaml          (Documentation server)
├── docs/
│   └── ARCHITECTURE.md           (Deep dive architecture)
├── quick-start.sh                (Automated setup script)
├── GETTING_STARTED.md            (3-step quick start)
├── SETUP.md                      (Detailed setup guide)
├── WORKFLOW.md                   (GitOps workflow guide)
├── MONITORING_SETUP.md           (Prometheus/Grafana guide)
├── DASHBOARDS.md                 (Dashboard guide)
├── PROJECT_STRUCTURE.md          (Project layout)
├── CODIFICATION_SUMMARY.md       (What's versioned in git)
└── README.md                     (This file)
```

## How It Works

### GitOps Flow

```
Your Git Repo (manifests)
         ↓
    ArgoCD watches
         ↓
  Auto-syncs to cluster
         ↓
  Applications running
```

### Monitoring Flow

```
K8s Cluster (nodes, pods, API)
         ↓
Prometheus (scrapes metrics)
         ↓
Grafana (visualizes data)
         ↓
Pre-built dashboards
```

## Key Features

✅ **Fully Codified** - All infrastructure defined in git-versioned YAML
✅ **GitOps Ready** - Deploy apps by pushing to git
✅ **Monitoring Included** - Prometheus + Grafana pre-configured
✅ **Zero Auth** - Anonymous access for local development
✅ **Production-Like** - Uses real K8s components (K3s)
✅ **Lightweight** - Runs on a single laptop
✅ **Well Documented** - Interactive guides included

## Common Tasks

### Deploy a New App via GitOps

1. Create a git repo with K8s manifests
2. In ArgoCD UI, click "+ New App"
3. Point to your repo and cluster
4. ArgoCD auto-deploys and keeps in sync

See `WORKFLOW.md` for detailed example.

### View Cluster Metrics

1. Open Grafana at http://localhost:3000
2. Select a dashboard from the menu
3. Explore node, pod, and API server metrics

See `DASHBOARDS.md` for dashboard guide.

### Troubleshooting

**Port-forward closed?**
```bash
ps aux | grep port-forward  # Check what's running
# Re-run port-forward command above
```

**Pods not starting?**
```bash
kubectl get pods -A                    # See all pods
kubectl describe pod <name> -n <ns>    # See errors
kubectl logs <pod> -n <ns>             # View logs
```

**Cluster down?**
```bash
colima stop && colima start --kubernetes
```

## Documentation

All guides are available on the **Documentation Server** (http://localhost:7777):

- **GETTING_STARTED.md** - 3-step quick start
- **SETUP.md** - Detailed installation walkthrough
- **WORKFLOW.md** - How to use GitOps (ArgoCD)
- **MONITORING_SETUP.md** - Prometheus and Grafana setup
- **DASHBOARDS.md** - How to use Grafana dashboards
- **PROJECT_STRUCTURE.md** - Project file layout
- **CODIFICATION_SUMMARY.md** - What's version controlled
- **ARCHITECTURE.md** - Deep technical overview

## Architecture Overview

### Kubernetes Cluster
- **Colima VM** - Lightweight virtualization
- **K3s** - Minimal Kubernetes distribution
- **kubelet** - Node agent managing pods
- **etcd** - Distributed config database

### GitOps Layer
- **ArgoCD Server** - REST API + web UI
- **ArgoCD Repo Server** - Git integration
- **ArgoCD Controller** - Reconciliation engine

### Monitoring Stack
- **Prometheus** - Time-series metrics database
- **Grafana** - Metrics visualization
- **node-exporter** - Node-level metrics
- **kube-state-metrics** - K8s object metrics

### User Interfaces
- **Dashboard** - Service hub and quick links
- **Documentation** - Interactive markdown guides
- **ArgoCD UI** - Application management
- **Grafana UI** - Metrics dashboards

## What's Next

1. **Deploy an App** - Follow `WORKFLOW.md` to deploy via GitOps
2. **Explore Dashboards** - Open Grafana and monitor your cluster
3. **Learn Architecture** - Read `ARCHITECTURE.md` for deep dive
4. **Modify for Your Needs** - Edit manifests and watch ArgoCD sync

## Resources

- [ArgoCD Docs](https://argo-cd.readthedocs.io/)
- [Prometheus Docs](https://prometheus.io/docs/)
- [Grafana Docs](https://grafana.com/docs/)
- [Kubernetes Docs](https://kubernetes.io/docs/)
- [K3s Docs](https://docs.k3s.io/)

## License

MIT - Free to use for learning and development

## Author

Built as a comprehensive learning project for local Kubernetes development with modern DevOps practices.
