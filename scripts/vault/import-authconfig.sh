# Check if Kubernetes auth is already enabled
if ! vault auth list | grep -q 'kubernetes/'; then
  echo "Enabling Kubernetes auth method..."
  vault auth enable kubernetes
fi
vault write auth/kubernetes/config @kubernetes_auth_config.json
