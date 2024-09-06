# Managing app secrets

!!! Warning "Protect secrets in Vault"
    The whole point of this is to keep secrets in Vault. DO NOT commit any secrets to the git repo directly.

## Introduction

We keep secrets in Vault, not in git. We use [External Secrets Operator](https://external-secrets.io/latest/) (ESO) to sync secrets from Vault into Kubernetes. In this model, Vault becomes the source of truth for secrets. Changing a secret value in Kubernetes will not achieve much since it will be overwritten by ESO. Therefore, in order to set or change a secret, it should always be done through Vault.

In Vault, secrets are organised by applications, and each application is isolated for security: an application is only ever able to retrieve their own secrets (and not that of a different application).
This is implemented via a combination of the following:

* Each application puts secrets under a different Vault path (e.g. `app/harbor`).
* Each application has a Vault role and policy that implements read-only access to their path.
* Each application has a Kubernetes Service Account and CRB that binds them to the role and policy setup in Vault, effectively limiting what they can access.

This involves a bit of boiler plate that needs to be configured once per application, but it can very easily be replicated using existing apps as templates. The details of the procedure for adding or managing secrets to an application follow below.


Vault side:

* [Connect to Vault](#connect-to-vault).
* [Add the desired secrets](#add-the-desired-secrets).
* [Create the application role](#create-the-application-role) (once per app).
* [Create the application policy](#create-the-application-policy) (once per app).

Kubernetes side:

* [Declare the app Cluster Role Binding (once per app)](#kubernetes-side-declarations)
* [Declare the Service Account (once per app)](#kubernetes-side-declarations)
* [Declare the SecretStore (once per app)](#kubernetes-side-declarations)
* [Declare ExternalSecret for each secret](#kubernetes-side-declarations)

!!! Tip
    If you want to export secrets, roles, and policies from Vault (as well as the equivalent import), please see the `scripts/vault` directory at the root of the repo.

## Connect to Vault

Secret Management is done via Vault, which is the source of truth. You'll need to kube-proxy to the Vault pod to be able to connect to it via web UI or via CLI:

```bash
kubectl port-forward vault-0 8200:8200 -n vault
```

You'll need a valid Vault token 🔑 (`VAULT_TOKEN`) for this, as well as to set `VAULT_ADDR=http://127.0.0.1:8200`. If you're also interacting with the CLI, set `VAULT_SKIP_VERIFY=true` as well.

## Add the desired secrets

Secrets can be added via the Web UI at [http://localhost:8200](http://localhost:8200), assuming you've done the connection to Vault above.

In Vault terms, a Secret (written in uppercase, to take the Vault-specific meaning of Secret) is a dictionary that can consist of multiple individual secret values, where the key is the name of the secret, and the value is the secret itself. The Vault Secret (the dict) has to be given a name.
We place Secrets under the `app/` _secret engine_, and each Secret is named after the corresponding app for which we want to define a set of secrets. The keys and values that each Secret is populated with will be visible on the Kubernetes side.

For instance for external-dns, under `app` you would create a secret named `external-dns` containing key `gandi-externaldns-key` and value `<redacated>`. You could add an arbitrary number of secrets for external-dns by adding multiple key/value pairs.

CLI example:

```bash
vault kv put app/my-app clientsecret="XYZ"
```

## Create the application policy

!!! info
    This only needs to be done once per application.

Create a policy for this application to read from the corresponding path.
This ensures that only this application is able to read its own secrets.

CLI example:

```bash
vault policy write my-app-policy - <<EOF
path "app/data/my-app" {
   capabilities = ["read"]
}
EOF
Success! Uploaded policy: my-app-policy
```

## Create the application role

!!! info
    This only needs to be done once per application.

Create a role that binds the policy to the Kubernetes service account and Kubernetes namespace of the application.

CLI example:

```bash
vault write auth/kubernetes/role/my-app \
      bound_service_account_names=myapp-vault \
      bound_service_account_namespaces=myapp \
      policies=my-app-policy \
      ttl=24h
Success! Data written to: auth/kubernetes/role/my-app-policy
```

## Kubernetes side declarations

The following example includes the declarations for the Kubernetes resources so that the External Secrets Operator is able to synchronise the secrets from Vault into the desird Kubernetes namespace. It can be roughly summarised as follows:

* Define a ServiceAccount for this application.
* Add the service account to the Vault rolebinding
* Create a SecretStore resource that defines the Vault instance to connect to, and the Vault role and service account that is associated with the secret to sync.
* Create an ExternalSecret  resource that connects the SecretStore  with a Kubernetes Secret  that is to be created and that will contain the secret from Vault.

You can see an example of how a secret is synchronised in the http-echo app's `secrets.yaml`, or below.

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: http-echo
  namespace: http-echo
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: http-echo-vault-access
roleRef:
  kind: ClusterRole
  name: system:auth-delegator
  apiGroup: rbac.authorization.k8s.io
subjects:
  - kind: ServiceAccount
    name: http-echo
    namespace: http-echo
---
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: http-echo
  namespace: http-echo
spec:
  provider:
    vault:
      server: "http://vault.vault.svc.cluster.local:8200"
      path: "app"
      version: "v2"
      auth:
        kubernetes:
          # Path where the Kubernetes authentication backend is mounted in Vault
          mountPath: "kubernetes"
          # A required field containing the Vault Role to assume.
          role: "http-echo"
          # Optional service account field containing the name
          # of a kubernetes ServiceAccount
          serviceAccountRef:
            name: "http-echo"
---
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: http-echo
  namespace: http-echo
spec:
  refreshInterval: "15s" # time to sync from vault
  secretStoreRef:
    name: http-echo
    kind: SecretStore
  target:
    name: http-echo-example-secret-from-vault
    creationPolicy: Owner # create secret if not exists
  data:
    - secretKey: example-secret
      remoteRef:
        key: app/data/http-echo # path to secret in vault
        property: example-secret # key in the vault secret
```