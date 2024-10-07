# Vault Setup

## Installation

Vault should be installed by ArgoCD.

However, upon installation, Vault will be uninitialised.
In order to initialise Vault, one will need to:

1. Connect to Vault
1. Initialise Vault and save the unseal keys
1. Unseal Vault
1. Configure policies and secrets

## Connect to Vault

First, establish a connection to Vault.

```
kubectl port-forward svc/vault -n vault 8200:8200
export VAULT_ADDR=http://127.0.0.1:8200
export VAULT_SKIP_VERIFY=true
```

## Initialisation (Unseal)

This will initialise Vault and generate new unseal keys.

```
vault operator init | tee secrets-delme.txt
```

!!! danger
    The output from this command contains critical security keys.
    They can be used to recover every secret in Vault, so handle with care.
    These keys will be necessary to unseal if Vault is re-sealed
    (can happen when restarted or stopped).

Save the output to a secret in the Vault namespace,
and then immediately delete the local copy of the secrets.
This will allow anybody with admin rights to the cluster to recover Vault.

```
kubectl create secret generic unseal-keys --from-file=keys=secrets-delme.txt --namespace=vault && rm secrets-delme.txt
```

Now it's time to unseal. Run the following command until Vault is unsealed. By default it will take 3 runs using 3 different unseal keys.

```
vault operator unseal
```

## Recover the token

If one ever needs to recover the token or keys, one can read it from the `unseal-keys` secret in the `vault` namespace, as follows:

```
# Get the token to log in with
kubectl get secret unseal-keys -n vault -o jsonpath='{.data}' | jq -r 'to_entries[] | "\(.key): \(.value | @base64d)"'
```

## Configuration

To configure Vault, one needs to:

* Setup kubernetes authconfig and app roles.
* Create policies for each application.
* Create secret engine with at least a Secret per app.

The quickest to configure Vault is to restore a previous working configuration
from an [export/backup](#exportbackup-config), using the scripts under `scripts/vault/`.

When starting a new installation, however, one may want to use new secret values.
In that case, one can still follow the backup restore process,
but then either edit the secrets to use new ones,
or simply not import the secrets and create them by hand.

The following assumes that one previously created a [backup](#exportbackup-config) of all Vault
configuration and secrets under `scripts/vault/export` using the provided export scripts.

```
cd scripts/vault/export
../import/import-authconfig.sh
../import/import-policies.sh
../import/import-roles.sh
../import/import-secrets.sh
```

!!! Tip
    If any secrets fail syncing due to permission denied,
    make sure the policy and role is properly configured.
    Also check that the kubernetes auth role's **token policy** is set accordingly.

## Export/Backup Config

To backup the Vault config, one can use the scripts under `scripts/vault/`.

The scripts will just write to the working directory, so create a new directory to store the export.
For instance:

```
cd scripts/vault
mkdir export
cd export
```

Then run the export scripts.

Each of them saves a different part of the Vault configuration as different
files to the working dir, the last one being the secrets themselves,
so be careful to not leave them in your hard drive unprotected for long.

```
../export-authconfig.sh
../export-roles.sh
../export-policies.sh
../export-secrets.sh
```