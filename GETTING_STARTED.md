# Getting Started: 3-Step Guide

You've got a fresh project! Here's what to do next.

## Step 1: Get a K8s Cluster Running

Choose one:

**Option A: Docker Desktop (macOS, easiest)**
- Already have Docker Desktop? Great!
- Preferences → Kubernetes → Enable Kubernetes
- Takes 2 minutes to start
- Verify: `kubectl cluster-info`

**Option B: Minikube (lightweight)**
```bash
brew install minikube
minikube start --cpus=4 --memory=4096
```

**Don't have either?**
- Install Docker Desktop from https://www.docker.com/products/docker-desktop

## Step 2: Run the Quick-Start Script

```bash
cd ~/projects/local-k8s-argocd
chmod +x quick-start.sh
./quick-start.sh
```

This installs ArgoCD and shows you the admin password.

## Step 3: Access ArgoCD UI

In **one terminal**:
```bash
kubectl port-forward -n argocd svc/argocd-server 8080:443
```

In your browser:
- Go to `https://localhost:8080`
- Click past the TLS warning (self-signed cert)
- Username: `admin`
- Password: (from the script output)

**That's it!** You now have:
- ✅ Local K8s cluster
- ✅ ArgoCD running on it
- ✅ Access to the UI

## What You're Looking At

The ArgoCD UI shows:
- **Applications** - your deployed apps
- **Repositories** - where ArgoCD watches for manifests
- **Server Info** - cluster & version details

It's pretty empty right now because you haven't deployed anything yet.

## Next: Deploy Something

When you're ready, head to `WORKFLOW.md` to:
1. Create a git repo with K8s manifests
2. Tell ArgoCD about it
3. Watch it auto-deploy

## Troubleshooting

**"kubectl: command not found"**
→ Install Docker Desktop or minikube

**"Cluster info" fails**
→ Docker Desktop: enable K8s in Preferences
→ Minikube: run `minikube start`

**Can't access `localhost:8080`**
→ Forget the port-forward? Run it again in a terminal
→ Already running? Great, reload the page

**ArgoCD pods not starting**
→ Check: `kubectl get pods -n argocd`
→ Watch logs: `kubectl logs -n argocd -l app.kubernetes.io/name=argocd-server`

## Files in This Project

- `SETUP.md` - Detailed explanation of each step
- `WORKFLOW.md` - How to use ArgoCD (the GitOps way)
- `docs/ARCHITECTURE.md` - Deep dive into what's running
- `quick-start.sh` - Automated install script
- `manifests/` - Where you'll put your K8s YAML files (for now, empty)

---

**Good luck!** You're building real infrastructure. This setup is exactly what teams use in production (minus the "local" part).
