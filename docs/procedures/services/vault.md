# Vault Procedures

## Recover the root token or unseal keys

If one ever needs to recover the root token or keys, one can read it from the `unseal-keys` secret in the `vault` namespace, as follows:

```bash
# Get the token to log in with
kubectl get secret unseal-keys -n vault -o jsonpath='{.data}' | jq -r 'to_entries[] | "\(.key): \(.value | @base64d)"'
```

## Connecting to Vault

First, establish a connection to Vault.

!!! Tip "Tip when connecting from a multi-node frontend (such as ela)"
    Make sure that your Vault commands are run from the same node where you port-forwarded to vault.

```bash
kubectl port-forward svc/vault -n vault 8200:8200
```

From second shell on the same node.

!!! Tip "Do not expose the Vault token in your bash history"
    The command below will read your token into the VAULT_TOKEN environment variable

```bash
export VAULT_ADDR=http://127.0.0.1:8200
export VAULT_SKIP_VERIFY=true
read -s VAULT_TOKEN
```

Now you can use the [vault cli](https://developer.hashicorp.com/vault/install) (e.g. by running the scripts from the cloned repo).
To verify that your connection to Vault is working as expected, you can run any vault command such as `vault auth list`.

## Unsealing Vault

Run the following command until Vault is unsealed. By default it will take 3 runs using 3 different unseal keys.

```bash
vault operator unseal
```