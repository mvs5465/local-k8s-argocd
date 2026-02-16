# Architecture Explained

## What's Actually Running

### On Your Laptop

```
Your Machine
├─ Docker Desktop (or minikube)
│  └─ Kubernetes Cluster
│     ├─ System pods (kube-system namespace)
│     │  ├─ kube-apiserver (brain of K8s)
│     │  ├─ kube-scheduler (assigns pods to nodes)
│     │  ├─ kube-controller-manager (maintains state)
│     │  └─ etcd (database of all config)
│     │
│     ├─ ArgoCD pods (argocd namespace)
│     │  ├─ argocd-server (REST API + UI)
│     │  ├─ argocd-repo-server (reads git)
│     │  ├─ argocd-controller-manager (watches & syncs)
│     │  ├─ argocd-redis (cache)
│     │  └─ argocd-dex (auth)
│     │
│     └─ Your apps (whatever you deploy)
│        └─ Deployments, Pods, Services, etc
│
└─ Port forwarding: localhost:8080 → argocd-server
```

## How It Works

### The Install Process

1. **You run** `kubectl apply -f argocd-manifests.yaml`
   - This is YAML describing ArgoCD itself
   - kubectl sends it to kube-apiserver

2. **kube-apiserver** stores it in etcd
   - Says "okay, I need these pods"

3. **kube-scheduler** places them
   - "I'll put these on the available node"

4. **kube-controller-manager** starts them
   - Tells Docker to pull images and run containers

5. **Pods start** running inside containers
   - ArgoCD components now live in your cluster

### The GitOps Loop

```
┌─────────────────────────────────────────┐
│ Your Git Repo                           │
│ (YAML manifests = desired state)        │
└────────┬────────────────────────────────┘
         │ ArgoCD polls every 3 min
         ▼
┌─────────────────────────────────────────┐
│ argocd-repo-server                      │
│ (clones repo, reads manifests)          │
└────────┬────────────────────────────────┘
         │ compares with
         ▼
┌─────────────────────────────────────────┐
│ K8s Cluster (current state)             │
│ (what's actually running)               │
└────────┬────────────────────────────────┘
         │ if different:
         ▼
┌─────────────────────────────────────────┐
│ argocd-controller-manager               │
│ (applies changes via kube-apiserver)    │
└─────────────────────────────────────────┘
         │ syncs cluster
         ▼
    Cluster matches Git ✅
```

## Key Insight: Namespaces

A namespace is like a folder. Keeps things organized.

- `argocd` namespace: ArgoCD itself
- `default` namespace: Your apps (usually)
- `kube-system` namespace: K8s internals
- `kube-public` namespace: Public configs

You can have multiple apps in `default` (or different namespaces).

```bash
# See pods in a namespace
kubectl get pods -n argocd
kubectl get pods -n default

# See all namespaces
kubectl get namespaces
```

## Why Local K8s Matters

Learning ArgoCD requires a cluster. Options:

| Option | Pros | Cons |
|--------|------|------|
| **Docker Desktop K8s** | Integrated, simple | Resource heavy |
| **Minikube** | Lightweight, easy reset | Separate tool |
| **Cloud (AWS/GCP)** | Real-world experience | Costs $$ |
| **KinD** | Fast, containerized | Newest, less docs |

For learning: Docker Desktop or Minikube are best.

## Next: Connecting Your Laptop to a Git Repo

When you're ready to try WORKFLOW.md:

1. Create a git repo (GitHub, GitLab, or local)
2. Put K8s manifests (YAML files) in it
3. Tell ArgoCD about that repo
4. ArgoCD continuously syncs it to your cluster

That's the whole GitOps philosophy!
