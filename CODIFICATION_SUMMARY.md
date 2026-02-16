# Codification Summary: What's in Git vs What's Manual

## The Git Repository (Versioned & Reproducible)

```
📦 local-k8s-argocd/
│
├── 📄 README.md
│   └─ Project overview
│
├── 📄 GETTING_STARTED.md
│   └─ How to get K8s + ArgoCD running
│
├── 📄 quick-start.sh
│   └─ Automated ArgoCD installation script
│   └─ Creates namespace, applies official manifests, gets password
│
├── 📁 manifests/  (THE CORE IaC)
│   ├─ grafana-app.yaml
│   │  └─ ArgoCD Application CRD
│   │  └─ Specifies: Helm chart, version, resource limits, datasources
│   │  └─ This = "deploy Grafana exactly like this"
│   │
│   └─ prometheus-app.yaml
│      └─ ArgoCD Application CRD
│      └─ Specifies: Helm chart, version, storage, exporters
│      └─ This = "deploy Prometheus exactly like this"
│
├── 📁 docs/
│   └─ ARCHITECTURE.md - Learning reference
│
└── 📄 Documentation files
   └─ SETUP.md, WORKFLOW.md, MONITORING_SETUP.md, etc.
```

## The Execution Flow (What Happens)

### ✅ CODIFIED IN GIT

```
Git Repo (manifests/)
    ↓
ArgoCD watches git
    ↓
ArgoCD sees Application CRD
    ↓
ArgoCD applies Helm charts using values in YAML
    ↓
Grafana + Prometheus running on cluster
    ↓
Changes: Edit YAML → git push → ArgoCD syncs automatically
```

### ❌ MANUAL (NOT IN GIT)

```
Your laptop
    ↓
brew install colima docker kubectl
    ↓
colima start --kubernetes
    ↓
./quick-start.sh
    ↓
kubectl port-forward ... (3 separate commands)
    ↓
K8s cluster is up + accessible
```

## File-by-File Breakdown

### `manifests/grafana-app.yaml`
**Type:** Kubernetes Application (ArgoCD CRD)
**What it does:**
```
Tells ArgoCD: "Install Grafana from Helm chart v8.3.0 with these settings"
```

**Codified aspects:**
- Helm chart source: `https://grafana.github.io/helm-charts`
- Chart version: `8.3.0` (pinned!)
- Admin password: `admin`
- Resource requests: 100m CPU, 128Mi memory
- Resource limits: 500m CPU, 512Mi memory
- Service type: LoadBalancer
- Datasource: Points to `http://prometheus:9090`
- Sync policy: Auto-prune, self-heal
- Namespace: `monitoring` (auto-created)

**If you change it:**
```bash
# Edit the file
vim manifests/grafana-app.yaml

# Push to git
git commit -am "Change Grafana replicas to 2"
git push

# ArgoCD detects change automatically
# Within 3 minutes, Grafana has 2 replicas
```

### `manifests/prometheus-app.yaml`
**Type:** Kubernetes Application (ArgoCD CRD)
**What it does:**
```
Tells ArgoCD: "Install Prometheus from Helm chart v25.3.1 with these settings"
```

**Codified aspects:**
- Helm chart source: `https://prometheus-community.github.io/helm-charts`
- Chart version: `25.3.1` (pinned!)
- CPU/memory limits: 100m/256Mi requests, 500m/512Mi limits
- Storage: 2Gi persistent volume
- Retention: 7 days
- Includes: node-exporter, kube-state-metrics
- Excludes: pushgateway, alertmanager (disabled)
- Service type: LoadBalancer
- Sync policy: Auto-prune, self-heal

### `quick-start.sh`
**Type:** Bash installation script
**What it does:**
```bash
#!/bin/bash
1. Create argocd namespace
2. Download official ArgoCD manifests from GitHub
3. Apply them to cluster
4. Wait for pods to be ready
5. Extract initial admin password
6. Print access instructions
```

**Why it's needed:** ArgoCD itself must be installed before it can manage other apps.

## What This Means Practically

### Scenario: You want 3 Grafana replicas instead of 1

**Current (manual):** You'd have to scale via kubectl
```bash
kubectl scale deployment grafana -n monitoring --replicas=3
```
But next time you restart, it's back to 1. Not declarative.

**With codification:** Edit the YAML
```yaml
# manifests/grafana-app.yaml
spec:
  source:
    helm:
      values: |
        replicas: 3  # <-- change this
```

Push → ArgoCD syncs → Always 3 replicas, even after restarts.

### Scenario: Prometheus is breaking, need to downgrade version

**Current (manual):** Would need to manually re-install, recreate config, etc.

**With codification:**
```yaml
targetRevision: 25.2.0  # <-- change from 25.3.1
```

Push → ArgoCD downgrades automatically, keeps your data.

## The Gaps (What's Not Codified)

| Thing | Current | To Codify |
|-------|---------|-----------|
| Colima VM setup | Manual brew install | Terraform + Makefile |
| K3s cluster | Manual `colima start` | Colima profile config |
| Port-forwarding | Manual shell background | Systemd services |
| Grafana dashboards | Created via UI | ConfigMaps in manifests/ |
| Secrets (passwords) | In manifests (⚠️) | Sealed secrets or Vault |

## Security Note

**⚠️ IMPORTANT:** Your admin passwords are in git right now:
```yaml
adminPassword: admin  # <-- visible in git
```

For production, use:
- [Sealed Secrets](https://sealed-secrets.netlify.app/)
- [External Secrets Operator](https://external-secrets.io/)
- HashiCorp Vault
- AWS Secrets Manager

For personal laptop: fine, but bad habit.

## Summary

**You have:**
- ✅ ArgoCD installation codified (script)
- ✅ Grafana deployment codified (YAML)
- ✅ Prometheus deployment codified (YAML)
- ✅ All backed by Git
- ❌ Cluster provisioning NOT codified (manual)
- ❌ Port-forwarding NOT codified (manual)

**This is 80% of the way to production-ready IaC.** The remaining 20% is automating local machine setup, which isn't critical for a personal cluster.
