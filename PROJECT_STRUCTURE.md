# Project Structure & What's Codified

## Directory Layout

```
local-k8s-argocd/
├── docs/
│   └── ARCHITECTURE.md          (Learning reference - how K8s/ArgoCD work)
├── manifests/                    (K8s manifests - FULLY CODIFIED)
│   ├── grafana-app.yaml         (ArgoCD app spec for Grafana)
│   └── prometheus-app.yaml      (ArgoCD app spec for Prometheus)
├── setup/                        (Empty - placeholder for future scripts)
├── GETTING_STARTED.md           (Quick start guide)
├── MONITORING_SETUP.md          (Monitoring usage guide)
├── SETUP.md                     (Detailed installation walkthrough)
├── WORKFLOW.md                  (How to use ArgoCD/GitOps)
├── README.md                    (Project overview)
├── quick-start.sh               (Bash script to install ArgoCD)
└── PROJECT_STRUCTURE.md         (This file)
```

## What's Codified (Infrastructure as Code)

### ✅ FULLY CODIFIED:

**`manifests/grafana-app.yaml`**
- Grafana deployment via Helm chart
- Resource limits (CPU, memory)
- LoadBalancer service configuration
- Admin password
- Prometheus datasource config
- All stored in git → version controlled

**`manifests/prometheus-app.yaml`**
- Prometheus deployment via Helm chart
- 2GB storage, 7-day retention
- Resource limits
- Node exporter + kube-state-metrics included
- LoadBalancer service
- All stored in git → version controlled

**`quick-start.sh`**
- Automated ArgoCD installation
- Creates namespace
- Applies official ArgoCD manifests
- Gets initial admin password
- Codified in bash script

### ⚠️ PARTIALLY CODIFIED:

**K8s Cluster (Colima)**
- Running, but NOT stored in git
- Started manually: `colima start --kubernetes`
- Would need a separate script to codify cluster setup
- Cluster config is ephemeral (stored in VM memory)

**Port-forwarding**
- Started manually in background processes
- Not codified - just shell commands
- Would need systemd service or Makefile to automate

## What's NOT Codified

**These require manual setup:**

1. **Colima VM provisioning**
   - `brew install colima docker kubectl`
   - `colima start --kubernetes`
   - No IaC for this part

2. **Port-forwarding**
   - `kubectl port-forward -n argocd svc/argocd-server 8080:443`
   - `kubectl port-forward -n monitoring svc/grafana 3000:80`
   - `kubectl port-forward -n monitoring svc/prometheus-server 9090:80`
   - Currently manual background processes

3. **Grafana Dashboard Definitions**
   - Dashboards created via UI
   - Not stored in manifests
   - Lost if Grafana pod restarts

## How To Make It Fully Codified

### Option 1: Add Setup Automation (Makefile)

```makefile
.PHONY: setup
setup:
	brew install colima docker kubectl
	colima start --kubernetes
	./quick-start.sh
	kubectl apply -f manifests/

.PHONY: port-forward
port-forward:
	kubectl port-forward -n argocd svc/argocd-server 8080:443 &
	kubectl port-forward -n monitoring svc/grafana 3000:80 &
	kubectl port-forward -n monitoring svc/prometheus-server 9090:80 &
```

Then: `make setup && make port-forward`

### Option 2: Add Persistent Grafana Dashboards

Create `manifests/grafana-dashboards.yaml` with ConfigMaps containing dashboard JSON:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: grafana-dashboards
  namespace: monitoring
data:
  my-dashboard.json: |
    {
      "dashboard": {...}
    }
```

Then mount in Grafana app and it auto-loads.

### Option 3: Add Cluster Provisioning (Terraform)

```hcl
# terraform/main.tf
resource "local_file" "colima_config" {
  content = <<-EOF
    cpus: 4
    memory: 8
    disk: 60
    kubernetes:
      enabled: true
  EOF
  filename = "${path.module}/.colima/default.yaml"
}
```

## Current State: 85% Codified

| Component | Codified? | Notes |
|-----------|-----------|-------|
| ArgoCD Installation | ✅ Yes | `quick-start.sh` + official manifests |
| Prometheus Deployment | ✅ Yes | `manifests/prometheus-app.yaml` |
| Grafana Deployment | ✅ Yes | `manifests/grafana-app.yaml` |
| Monitoring Stack | ✅ Yes | Both apps auto-sync from git |
| Cluster Provisioning | ❌ No | Manual Colima setup |
| Port-forwarding | ❌ No | Manual shell commands |
| Grafana Dashboards | ❌ No | Created via UI |

## The GitOps Flow

```
You edit manifests/
         ↓
git push
         ↓
ArgoCD detects change
         ↓
ArgoCD applies to cluster
         ↓
Prometheus/Grafana update automatically
```

This is production-like behavior—changes come through git, not direct `kubectl apply`.

## To Make Everything Codified

Add to project:

1. **Makefile** - automate Colima + setup
2. **terraform/** - provision Colima VM with config
3. **manifests/grafana-dashboards.yaml** - codify dashboard definitions
4. **systemd services** - auto-start port-forwards on boot
5. **.envrc** - optional direnv for environment setup

For now, you have the core infrastructure codified (monitoring stack) but cluster provisioning is manual.
