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
kubectl apply -f manifests/argocd/argocd-install.yaml

echo ""
echo "⏳ Waiting for ArgoCD server to be ready (this takes ~30-60 seconds)..."
kubectl wait -n argocd --for=condition=ready pod -l app.kubernetes.io/name=argocd-server --timeout=300s || {
    echo "⚠️  Timeout waiting for pods. Check status with:"
    echo "   kubectl get pods -n argocd"
    exit 1
}

echo ""
echo "✅ ArgoCD installed!"
echo ""

echo "📦 Deploying applications via root Application..."
kubectl apply -f manifests/argocd/appproject.yaml manifests/argocd/root-app.yaml

echo ""
echo "⏳ Waiting for applications to sync (this takes ~30 seconds)..."
kubectl wait -n argocd --for=condition=Synced application/root --timeout=300s || {
    echo "⚠️  Apps didn't sync. Check status with:"
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
