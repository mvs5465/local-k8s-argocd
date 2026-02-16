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
echo "🔄 Setting up ArgoCD namespace..."
kubectl create namespace argocd || true

echo ""
echo "📦 Installing ArgoCD..."
kubectl apply -n argocd --server-side --force-conflicts -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo ""
echo "⏳ Waiting for ArgoCD to be ready (this takes ~60 seconds)..."
kubectl wait -n argocd --for=condition=ready pod -l app.kubernetes.io/name=argocd-server --timeout=300s || {
    echo "⚠️  Timeout waiting for ArgoCD. Check status with:"
    echo "   kubectl get pods -n argocd"
    exit 1
}

echo ""
echo "📦 Bootstrapping with AppProject and root application..."
kubectl apply -f manifests/argocd/appproject.yaml -f manifests/argocd/root-app.yaml

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

echo "🌐 To access ArgoCD UI:"
echo "   Open: https://argocd.local"
echo "   (No login required - auth disabled for local dev)"
echo ""

echo "📚 All services are now running via ArgoCD:"
echo "   - See README.md for port-forwarding and architecture"
echo ""
