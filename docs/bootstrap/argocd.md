# ArgoCD installation and Setup

## Installation

Following https://argo-cd.readthedocs.io/en/stable/getting_started/.

Caveats: Unfortunately the port-forward solution to connect to ArgoCD is broken, so we used:

```bash
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
```

to expose it as a Service. For security reasons, we should revise the above and not have ArgoCD exposed at all.

## Setup

### CLI login
The `--sso` option seems to use the wrong return_url (to be fixed). But login can happen with the admin user. The password is stored in the argocd namespace, the secret name is skach-argocd-admin.

Then you should be able to login using:

```bash
argocd login 148.187.17.54 --username admin --password $PASSWORD
```
(Or use the correct public IP if this has changed). If you run into issues, you may need to use `--insecure`  or `--port-forward-namespace` argocd options.

### OIDC Setup

See the OIDC [reference](https://argo-cd.readthedocs.io/en/stable/operator-manual/user-management/#existing-oidc-provider).

To setup SKA-IAM logins via sso we can apply some changes on Kubernetes resources:

In the `argocd` namespace, need to configure 2 configmaps:

In the `argocd-cm` ConfigMap, the url needs to match the hostname.

```yaml
data:
  oidc.config: |
    name: ska-iam
    issuer: https://ska-iam.stfc.ac.uk/
    clientID: <client_id>
    clientSecret: <client_secret>
  url: https://148.187.17.54/
```


In the `argocd-rbac-cm` ConfigMap:

```yaml
data:
  policy.csv: |
    p, role:ska-admin, applications, create, */*, allow
    p, role:ska-admin, applications, update, */*, allow
    p, role:ska-admin, applications, delete, */*, allow
    p, role:ska-admin, applications, sync, */*, allow
    p, role:ska-admin, applications, override, */*, allow
    p, role:ska-admin, applications, action/*, */*, allow
    p, role:ska-admin, applications, *, */*, allow
    p, role:ska-admin, applicationsets, get, */*, allow
    p, role:ska-admin, applicationsets, create, */*, allow
    p, role:ska-admin, applicationsets, update, */*, allow
    p, role:ska-admin, applicationsets, delete, */*, allow
    p, role:ska-admin, certificates, create, *, allow
    p, role:ska-admin, certificates, update, *, allow
    p, role:ska-admin, certificates, delete, *, allow
    p, role:ska-admin, clusters, create, *, allow
    p, role:ska-admin, clusters, update, *, allow
    p, role:ska-admin, clusters, delete, *, allow
    p, role:ska-admin, repositories, create, *, allow
    p, role:ska-admin, repositories, update, *, allow
    p, role:ska-admin, repositories, delete, *, allow
    p, role:ska-admin, projects, create, *, allow
    p, role:ska-admin, projects, update, *, allow
    p, role:ska-admin, projects, delete, *, allow
    p, role:ska-admin, accounts, update, *, allow
    p, role:ska-admin, gpgkeys, create, *, allow
    p, role:ska-admin, gpgkeys, delete, *, allow
    p, role:ska-admin, exec, create, */*, allow
    g, src/chsrc/admins, role:ska-admin
  policy.default: ""
```

This will enable SKA-IAM logins with admin access for members of src/chsrc/admins. All other users will still be able to (sort of) login (this is an ArgoCD limitation), but they will not have access to read or write anything.

### Helm kustomize support

To enable helm support for kustomizations, as well as loading values files from other directories.

In the `argocd-cm` ConfigMap:

```yaml
data:
  kustomize.buildOptions: --load-restrictor LoadRestrictionsNone --enable-helm
```

### Cilium caveat

CSCS Seems to instrument the cluster with Cilium, which seems to automatically add extra fields to Kubernetes resources. This confuses ArgoCD, thinking that the resources are OutOfSync. To remedy this, we can simply exclude these resources from Argo. In the argocd-cm ConfigMap (argocd namespace), we just need to add:

```yaml
resource.exclusions: |
    - apiGroups:
      - cilium.io
      kinds:
      - CiliumIdentity
      clusters:
      - "*"
```


