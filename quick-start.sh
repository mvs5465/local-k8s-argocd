#!/bin/bash
# Quick start script for local K8s + ArgoCD

set -e

echo "🚀 Local K8s + ArgoCD Quick Start"
echo "=================================="
echo ""

# Check kubectl
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl not found. Install Docker Desktop or minikube first."
    exit 1
fi

echo "✅ kubectl found"
kubectl version --client

echo ""
echo "📋 Cluster status:"
kubectl cluster-info || {
    echo "❌ No cluster running. Start Docker Desktop K8s or minikube."
    exit 1
}

echo ""
echo "🔄 Installing ArgoCD..."
kubectl create namespace argocd || true

echo "Downloading official ArgoCD manifest..."
curl -sL https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml | \
  kubectl apply -n argocd -f - 2>&1 | grep -v "Too long" || true

echo "Configuring ArgoCD (disabling auth)..."
kubectl apply -f manifests/argocd/argocd-config.yaml || true

echo "⏳ Waiting for ArgoCD server to be ready (this takes ~30-60 seconds)..."
kubectl wait -n argocd --for=condition=ready pod -l app.kubernetes.io/name=argocd-server --timeout=300s || {
    echo "⚠️  Timeout waiting for pods. Check status with:"
    echo "   kubectl get pods -n argocd"
    exit 1
}

echo ""
echo "✅ ArgoCD installed!"
echo ""

echo "📦 Deploying root Applications (app-of-apps)..."
kubectl apply -f manifests/argocd/appproject.yaml -f manifests/argocd/root-system-app.yaml -f manifests/argocd/root-apps-app.yaml

echo ""
echo "⏳ Waiting for applications to sync (this takes ~30 seconds)..."
kubectl wait -n argocd --for=condition=Synced application/root-system --timeout=300s || {
    echo "⚠️  System apps didn't sync. Check status with:"
    echo "   kubectl get app -n argocd"
}
kubectl wait -n argocd --for=condition=Synced application/root-apps --timeout=300s || {
    echo "⚠️  User apps didn't sync. Check status with:"
    echo "   kubectl get app -n argocd"
}

echo ""
echo "✅ All applications deployed!"
echo ""

echo "🌐 To access ArgoCD UI:"
echo "   1. Run: kubectl port-forward -n argocd svc/argocd-server 8080:443"
echo "   2. Open: https://localhost:8080"
echo "   3. No login required (auth disabled for local dev)"
echo ""

echo "📚 All services are now running via ArgoCD:"
echo "   - See README.md for port-forwarding and architecture"
echo ""
