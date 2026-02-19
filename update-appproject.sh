#!/bin/bash
# Update ArgoCD AppProject configuration
# Use this to apply AppProject changes without running full bootstrap

set -e

echo "📋 Updating AppProject..."
kubectl apply -f manifests/argocd/appproject.yaml

echo "✅ AppProject updated"
