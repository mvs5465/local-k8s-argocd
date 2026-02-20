#!/bin/bash
# Quick start script for local K8s + ArgoCD

set -e

echo "🚀 Local K8s + ArgoCD Quick Start"
echo "=================================="
echo ""

# Check kubectl and helm
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl not found. Install Docker Desktop or minikube first."
    exit 1
fi

if ! command -v helm &> /dev/null; then
    echo "❌ helm not found. Install helm first: brew install helm"
    exit 1
fi

echo "✅ kubectl found"
kubectl version --client
echo "✅ helm found"
helm version --short

echo ""
echo "📋 Cluster status:"
kubectl cluster-info || {
    echo "❌ No cluster running. Start Docker Desktop K8s or minikube."
    exit 1
}

echo ""
echo "🔄 Setting up ArgoCD namespace..."
kubectl create namespace argocd || true

echo ""
echo "📦 Adding ArgoCD Helm repository..."
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

echo ""
echo "📦 Installing ArgoCD via Helm..."
helm upgrade --install argocd argo/argo-cd -n argocd \
  --values manifests/argocd/values.yaml \
  --wait --timeout 5m

echo ""
echo "⏳ Waiting for ArgoCD to be ready (this takes ~60 seconds)..."
kubectl wait -n argocd --for=condition=ready pod -l app.kubernetes.io/name=argocd-server --timeout=300s || {
    echo "⚠️  Timeout waiting for ArgoCD. Check status with:"
    echo "   kubectl get pods -n argocd"
    exit 1
}

echo ""
echo "🔑 Configuring GitHub credentials for ArgoCD..."
GITHUB_TOKEN_FILE="$HOME/.secrets/github/token"
if [ -f "$GITHUB_TOKEN_FILE" ]; then
    GITHUB_TOKEN=$(cat "$GITHUB_TOKEN_FILE")
    kubectl create secret generic argocd-repo-creds \
      -n argocd \
      --from-literal=type=git \
      --from-literal=url=https://github.com/mvs5465 \
      --from-literal=username=mvs5465 \
      --from-literal=password="$GITHUB_TOKEN" \
      --dry-run=client -o yaml | kubectl apply -f -
    kubectl label secret argocd-repo-creds -n argocd \
      argocd.argoproj.io/secret-type=repo-creds --overwrite
    echo "✅ GitHub credentials configured"
else
    echo "⚠️  No token found at $GITHUB_TOKEN_FILE — skipping. ArgoCD will use unauthenticated access."
fi

echo ""
echo "📦 Applying AppProject..."
kubectl apply -f manifests/argocd/appproject.yaml

echo ""
echo "📦 Bootstrapping with root application..."
kubectl apply -f manifests/argocd/root-app.yaml

echo ""
echo "⏳ Waiting for applications to sync (this takes ~30 seconds)..."
for i in {1..60}; do
    SYNC_STATUS=$(kubectl get application root -n argocd -o jsonpath='{.status.sync.status}' 2>/dev/null)
    if [ "$SYNC_STATUS" = "Synced" ]; then
        break
    fi
    sleep 1
done

if [ "$SYNC_STATUS" != "Synced" ]; then
    echo "⚠️  Root app didn't sync. Check status with:"
    echo "   kubectl get applications -n argocd"
    exit 1
fi

echo ""
echo "✅ All applications deployed!"
echo ""
echo "📌 Next steps:"
echo ""
echo "1. Start port-forward (required to access services):"
echo "   sudo echo port-forward && sudo kubectl port-forward -n ingress-nginx svc/nginx-ingress-ingress-nginx-controller 80:80 443:443 > /dev/null 2>&1 &"
echo ""
echo "2. Add hostnames to /etc/hosts:"
echo "   127.0.0.1 argocd.local grafana.local prometheus.local homepage.local kuma.local"
echo ""
echo "3. Get ArgoCD admin password:"
echo "   kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath=\"{.data.password}\" | base64 -d"
echo ""
echo "4. Open browser:"
echo "   http://homepage.local"
echo ""
echo "All services are linked from the homepage dashboard."
echo ""
