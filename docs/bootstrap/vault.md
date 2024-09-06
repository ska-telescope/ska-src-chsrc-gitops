# Vault Setup

## Installation

Vault should be installed by ArgoCD.

## Recover the token

```
# Get the token to log in with
kubectl get secret unseal-keys-current -n vault -o jsonpath='{.data}' | jq -r 'to_entries[] | "\(.key): \(.value | @base64d)"'
 
# Open a shell on the vault pod and log in
kubectl exec -it vault-0 -n vault -- /bin/sh
/ $ vault login
Token (will be hidden):
```