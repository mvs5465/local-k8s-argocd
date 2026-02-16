# Setup Guide: Local K8s + ArgoCD

## Prerequisites

You'll need three main tools:
1. **Docker** (or Docker Desktop on macOS) - runs containers
2. **kubectl** - CLI to talk to your K8s cluster
3. **A K8s cluster** - we'll use Docker Desktop's built-in K8s or minikube

### Option A: Docker Desktop K8s (Easiest for macOS)

If you have Docker Desktop installed:
1. Open Docker Desktop → Preferences → Kubernetes
2. Check "Enable Kubernetes"
3. Wait for it to start (watch the icon in top menu bar)
4. Verify: `kubectl cluster-info`

**Pros**: Simple, integrates with Docker
**Cons**: Resource heavy

### Option B: Minikube (More control)

```bash
# Install minikube
brew install minikube

# Start cluster
minikube start --cpus=4 --memory=4096

# Verify
kubectl cluster-info
```

**Pros**: Lightweight, easy to reset
**Cons**: Separate from Docker Desktop

## Step 1: Verify Kubectl Works

```bash
kubectl get nodes
kubectl get pods --all-namespaces
```

Should show your cluster node(s) and system pods (CoreDNS, kube-proxy, etc).

## Step 2: Install ArgoCD

ArgoCD runs as pods in your cluster. We'll install it into an `argocd` namespace.

```bash
# Create namespace
kubectl create namespace argocd

# Install ArgoCD using official manifests
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Watch it start (takes ~30 seconds)
kubectl get pods -n argocd -w
```

You'll see several pods spin up:
- `argocd-server` - the UI
- `argocd-repo-server` - talks to git repos
- `argocd-controller-manager` - reconciles state
- `argocd-redis` - caching
- Others for cleanup and notifications

## Step 3: Access ArgoCD UI

ArgoCD doesn't expose itself to localhost by default. We need to port-forward:

```bash
# Forward port 8080 on your machine to ArgoCD's port 8080
kubectl port-forward -n argocd svc/argocd-server 8080:443

# In another terminal, get the initial password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

Then:
- Open browser to `https://localhost:8080`
- Username: `admin`
- Password: (from command above)
- **Accept the TLS warning** (self-signed cert)

## Step 4: Understand What Happened

**The K8s Cluster:**
- Your local machine now runs kubelet (K8s engine)
- Runs pods like any production cluster
- You manage it with `kubectl`

**ArgoCD:**
- Watches a Git repository for application manifests
- When you push changes to git, ArgoCD sees them and applies them to K8s
- UI lets you visualize apps and manually sync if needed

**Port-forwarding:**
- ArgoCD server is only accessible inside the cluster
- `port-forward` tunnels `localhost:8080` → K8s network → argocd-server:443
- This is temporary; if you close the terminal, the tunnel closes

## Next Steps

Once you're logged in to ArgoCD UI:
1. Create a Git repository for your app manifests
2. Create an ArgoCD "Application" that points to that repo
3. ArgoCD will automatically deploy (and keep in sync) your app

See WORKFLOW.md for an example.
