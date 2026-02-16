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
kubectl create namespace argocd || echo "⚠️  argocd namespace already exists"

echo "Applying ArgoCD manifests..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo ""
echo "⏳ Waiting for ArgoCD pods to be ready (this takes ~30-60 seconds)..."
kubectl wait -n argocd --for=condition=ready pod -l app.kubernetes.io/name=argocd-server --timeout=300s || {
    echo "⚠️  Timeout waiting for pods. Check status with:"
    echo "   kubectl get pods -n argocd"
    exit 1
}

echo ""
echo "✅ ArgoCD installed!"
echo ""
echo "🔑 Getting initial admin password..."
PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo "Password: $PASSWORD"
echo ""

echo "🌐 To access ArgoCD UI:"
echo "   1. Run: kubectl port-forward -n argocd svc/argocd-server 8080:443"
echo "   2. Open: https://localhost:8080"
echo "   3. Username: admin"
echo "   4. Password: (shown above)"
echo ""

echo "📚 Next steps:"
echo "   - Read WORKFLOW.md to deploy your first app"
echo "   - See SETUP.md for detailed explanation"
echo ""
