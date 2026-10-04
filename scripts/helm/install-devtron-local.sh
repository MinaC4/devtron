#!/usr/bin/env bash
set -euo pipefail

# Devtron installation for a cluster that already owns Argo CD/Workflows CRDs
# (for example, an OpenChoreo cluster). The post-renderer preserves those CRDs
# while installing Devtron's CI/CD stack and local MinIO storage.

CHART="${DEVTRON_CHART:-devtron/devtron-operator}"
NAMESPACE="${DEVTRON_NAMESPACE:-devtroncd}"

helm repo add devtron https://helm.devtron.ai >/dev/null 2>&1 || true
helm repo update devtron

helm upgrade --install devtron "$CHART" \
  --create-namespace \
  --namespace "$NAMESPACE" \
  --post-renderer "$(dirname "$0")/skip-existing-argocd-crds.rb" \
  --set 'installer.modules={cicd}' \
  --set argo-cd.enabled=false \
  --set minio.enabled=true \
  --wait \
  --timeout "${DEVTRON_HELM_TIMEOUT:-30m}"
