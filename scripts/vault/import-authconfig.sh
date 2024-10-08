# check and create secrets engine
if vault secrets list -format=json | \
   jq '."app/"' | grep -q null; then
    vault secrets enable -path=app kv-v2
else
    echo "Secrets engine already exists at /app"
fi

# Check if Kubernetes auth is already enabled
if ! vault auth list | grep -q 'kubernetes/'; then
  echo "Enabling Kubernetes auth method..."
  vault auth enable kubernetes
fi
vault write auth/kubernetes/config @kubernetes_auth_config.json
