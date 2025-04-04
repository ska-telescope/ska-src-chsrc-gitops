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

See [Connecting to Vault](../procedures/services/vault.md#connecting-to-vault),
and take into account that if Vault is being bootstrapped for the first time, you do not need VAULT_TOKEN,
as the keys will be created in the next step.

## Initialisation

This will initialise Vault and generate new unseal keys and a root token.

```bash
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

```bash
kubectl create secret generic unseal-keys --from-file=keys=secrets-delme.txt --namespace=vault && rm secrets-delme.txt
```

To recover the keys or root token, see [here](../procedures/services/vault.md#recover-the-root-token-or-unseal-keys).

## Unseal

Now it's time to unseal, see [unsealing Vault](../procedures/services/vault.md#unsealing-vault).

## Configuration

To configure Vault, one needs to:

* Setup kubernetes authconfig and app roles.
* Create policies for each application.
* Create secret engine with at least a Secret per app.

On a brand new Vault setup without any backed up config, one will have to enable the kv and authconfig.

```bash
vault secrets enable -path=app kv-v2
vault auth enable kubernetes
vault write auth/kubernetes/config kubernetes_host="https://kubernetes.default.svc"
```

However, the recommended and quickest to configure Vault is to restore a previous working configuration
from an [export/backup](#exportbackup-config), using the scripts under `scripts/vault/`.

When setting up on a new cluster, however, one may want to use new secret values.
In that case, one can still follow the backup restore process,
but then either edit the secrets to use new ones,
or simply not import the secrets and create them by hand.

The following assumes that one previously created a [backup](#exportbackup-config) of all Vault
configuration and secrets under `scripts/vault/export` using the provided export scripts.

```bash
cd scripts/vault/export
../import-authconfig.sh
../import-policies.sh
../import-roles.sh
../import-secrets.sh
```

!!! Tip
    If any secrets fail syncing due to permission denied,
    make sure that the **kubernetes auth role's token policy** is set accordingly.

    After fixing this, you might need to **revoke authentication leases** and **delete
    the corresponding ExternalSecret object** to trigger a re-auth and secret sync.

## Export/Backup Config

To backup the Vault config, one can use the scripts under `scripts/vault/`.

The scripts will just write to the working directory, so create a new directory to store the export.
For instance:

```bash
cd scripts/vault
mkdir export
cd export
```

Then run the export scripts.

Each of them saves a different part of the Vault configuration as different
files to the working dir, the last one being the secrets themselves,
so be careful to not leave them in your hard drive unprotected for long.

```bash
../export-authconfig.sh
../export-roles.sh
../export-policies.sh
../export-secrets.sh
```

It is expected that exporting/importing root doesn't work.