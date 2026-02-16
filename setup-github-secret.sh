#!/bin/bash
# Setup script to inject GitHub PAT secret into ArgoCD
# Usage: ./setup-github-secret.sh

set -e

PAT_FILE="$HOME/.secrets/gh-pat"

if [ ! -f "$PAT_FILE" ]; then
    echo "❌ Error: GitHub PAT not found at $PAT_FILE"
    echo ""
    echo "Setup instructions:"
    echo "1. Create ~/.secrets directory: mkdir -p ~/.secrets"
    echo "2. Add your GitHub PAT to: $PAT_FILE"
    echo "3. Run this script again"
    echo ""
    echo "To create a GitHub PAT:"
    echo "  - Go to https://github.com/settings/tokens"
    echo "  - Create 'Tokens (classic)'"
    echo "  - Scope: repo (full control of private repos)"
    echo "  - Save token to $PAT_FILE"
    exit 1
fi

PAT=$(cat "$PAT_FILE")

echo "✅ Found GitHub PAT"
echo "📝 Creating ArgoCD secret..."

# Create temporary manifest with PAT injected
cat > /tmp/github-secret-temp.yaml <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: github-creds
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
type: Opaque
stringData:
  type: git
  url: https://github.com/mvs5465/local-k8s-argocd
  username: mvs5465
  password: $PAT
EOF

kubectl apply -f /tmp/github-secret-temp.yaml
rm /tmp/github-secret-temp.yaml

echo "✅ GitHub secret created in ArgoCD"
echo ""
echo "Next steps:"
echo "  - Wait for root Application to sync: kubectl get app -n argocd"
echo "  - Check sync status: kubectl get app root -n argocd -w"
