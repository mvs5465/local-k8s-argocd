# ArgoCD Workflow: GitOps in Action

## The GitOps Model

Normal K8s: You run `kubectl apply` manually
→ **ArgoCD way**: You push to git, ArgoCD auto-deploys

```
Your Git Repo (manifests)
         ↓
    ArgoCD watches
         ↓
  Auto-syncs to cluster
```

## Example: Deploy a Simple App

### 1. Create a Git Repo for Your App

This is where your K8s manifests live.

```bash
# Could be a public repo on GitHub, or private, or even local
mkdir ~/my-app-manifests
cd ~/my-app-manifests
git init
```

### 2. Create a K8s Manifest

Create `~/my-app-manifests/app.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-app
  namespace: default
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx-app
  template:
    metadata:
      labels:
        app: nginx-app
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-app
  namespace: default
spec:
  type: LoadBalancer
  selector:
    app: nginx-app
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
```

Push to git:
```bash
git add .
git commit -m "Add nginx deployment"
git push
```

### 3. Tell ArgoCD About Your App (via UI)

1. In ArgoCD UI, click "+ New App"
2. Fill in:
   - **Application Name**: `my-nginx-app`
   - **Project**: `default`
   - **Repository URL**: (path to your manifests repo)
   - **Path**: `.` (or subdirectory if manifests are in a folder)
   - **Cluster**: `https://kubernetes.default.svc` (your local cluster)
   - **Namespace**: `default`
3. Click "Create"

### 4. Watch It Sync

ArgoCD will:
- See your manifests in git
- Create the deployment and service in your cluster
- Show you the app tree (Deployment → ReplicaSet → Pods → Containers)

Verify in K8s:
```bash
kubectl get deployment nginx-app
kubectl get svc nginx-app
kubectl get pods
```

### 5. Update Your App (The GitOps Way)

Now the power: to update, just change git!

```bash
# Edit your manifest
# Change image tag, replicas, whatever

git commit -am "Update nginx version"
git push

# Within seconds, ArgoCD detects the change
# and updates your cluster automatically
```

## Key Concepts

**Sync Status**:
- ✅ **Synced** - Git matches cluster
- ⚠️ **OutOfSync** - They differ (you ran kubectl apply manually, or git changed)
- When OutOfSync, ArgoCD can auto-fix or wait for you to click "Sync"

**Refresh**:
- ArgoCD polls git every 3 minutes
- Click "Refresh" in UI to check immediately

**Self-Healing**:
- If someone `kubectl delete` something, ArgoCD re-creates it
- Your git repo is the source of truth

## Why This Matters

- **Audit trail**: All changes in git history
- **Rollback**: `git revert` + push = instant rollback
- **Reproducibility**: Declarative manifests > imperative commands
- **Team collab**: PR reviews before deployment
