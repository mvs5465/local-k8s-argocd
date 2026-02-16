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
kubectl version --client --short

echo ""
echo "📋 Cluster status:"
kubectl cluster-info || {
    echo "❌ No cluster running. Start Docker Desktop K8s or minikube."
    exit 1
}

echo ""
echo "🔄 Installing ArgoCD..."
kubectl apply -f manifests/argocd/install.yaml

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

echo "🔐 Setting up GitHub authentication..."
./setup-github-secret.sh || {
    echo "⚠️  GitHub secret setup failed. Run ./setup-github-secret.sh manually."
    exit 1
}

echo ""
echo "⏳ Waiting for root Application to sync (this takes ~30 seconds)..."
kubectl wait -n argocd --for=condition=Synced application/root --timeout=300s || {
    echo "⚠️  Root app didn't sync. Check status with:"
    echo "   kubectl get app -n argocd"
    exit 1
}

echo ""
echo "✅ All applications deployed!"
echo ""

echo "🌐 To access services:"
echo "   1. Run: kubectl port-forward -n argocd svc/argocd-server 8080:443"
echo "   2. Open: https://localhost:8080"
echo "   3. Dashboard: http://localhost:8888"
echo "   4. Grafana: http://localhost:3000"
echo "   5. Prometheus: http://localhost:9090"
echo ""

echo "📚 Next steps:"
echo "   - Check app sync status: kubectl get app -n argocd"
echo "   - See README.md for architecture and port-forwarding"
echo ""
