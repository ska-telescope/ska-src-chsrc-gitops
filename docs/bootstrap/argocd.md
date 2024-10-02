# ArgoCD Installation and Setup

## Installation

The installation reference is <https://argo-cd.readthedocs.io/en/stable/getting_started/>.

More precisely:

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

If you didn't already, [install the local argocd
CLI](https://argo-cd.readthedocs.io/en/stable/cli_installation/).

Setup a port-forward to the argocd cluster:

### Connect to ArgoCD via port-forward

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

### Obtain initial admin password

Now we're able to retrieve the admin password:

```bash
argocd admin initial-password -n argocd
```

### Connecting to ArgoCD via web UI

You should now be able to login as `admin` to <https://localhost:8080/>.

### Connecting to ArgoCD via CLI

First, login via CLI. Assuming you've setup the port-forward as described above, you can do:

```
argocd login localhost:8080 --insecure
```

And now you should be able to run other commands such as:

```bash
argocd app list
```

### Expose ArgoCD (or not)

!!! Warning
    Only do this as a last resort, if case the port-forwarding solution does not work. Exposing ArgoCD is probably a bad idea.

If the port-forward solution to connect to ArgoCD is broken, you can use:

```bash
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
```

to expose it as a Service. For security reasons, the above should be revised to not have ArgoCD
exposed at all.

## Setup

### Quick Start

The following two configmaps are configured to setup ArgoCD for the CHSRC use cases.

It configures [OIDC access](#oidc-setup), enables [Helm Kustomize support](#helm-kustomize-support),
and configures ArgoCD to [ignore Cilium-related](#cilium-caveat) resources that are added to
our clusters behind the scenes.

To configure all of this, create these two files:

`argocd-cm.yaml`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-cm
  namespace: argocd
  labels:
    app.kubernetes.io/name: argocd-cm
    app.kubernetes.io/part-of: argocd
data:
  oidc.config: |
    name: ska-iam
    issuer: https://ska-iam.stfc.ac.uk/
    clientID: <client_id>
    clientSecret: <client_secret>
  url: https://localhost:8080/
  kustomize.buildOptions: --load-restrictor LoadRestrictionsNone --enable-helm
  resource.exclusions: |
    - apiGroups:
      - cilium.io
      kinds:
      - CiliumIdentity
      clusters:
      - "*"
```

`argocd-rbac-cm.yaml`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-rbac-cm
  namespace: argocd
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

Apply them:

```bash
kubectl apply -f argocd-rbac-cm.yaml -n argocd
kubectl apply -f argocd-cm.yaml -n argocd
```

!!! Info
    The OIDC client needs to have the `group` scope.

!!! Info
    If you generated a new client ID and secret, please add them to the [secrets table](../misc/locked-credentials.md).

At this point, we're done. For more details about what we just did in this
quickstart and why, see the sections below.

### OIDC Setup

See the OIDC
[reference](https://argo-cd.readthedocs.io/en/stable/operator-manual/user-management/#existing-oidc-provider).

To setup SKA-IAM logins via sso we can apply some changes on Kubernetes resources:

In the `argocd` namespace, need to configure 2 configmaps: `argocd-cm` and `argocd-rbac-cm`, as follows.

First, in the `argocd-cm` ConfigMap, configure oidc.config to talk to the IAM server,
 and the url to match the hostname.

```yaml
data:
  oidc.config: |
    name: ska-iam
    issuer: https://ska-iam.stfc.ac.uk/
    clientID: <client_id>
    clientSecret: <client_secret>
  url: https://148.187.17.54/
```

Then apply it.

```
kubectl apply -f argocd-cm.yaml -n argocd
```

Second, to configure the policies for OIDC user access based on their group membership,
Add the following to the `argocd-rbac-cm` ConfigMap:

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

This will enable SKA-IAM logins with admin access for members of src/chsrc/admins. All other users
will still be able to (sort of) login (this is an ArgoCD limitation), but they will not have access
to read or write anything.

### Helm Kustomize support

To enable helm support for kustomizations, as well as loading values files from other directories.

In the `argocd-cm` ConfigMap:

```yaml
data:
  kustomize.buildOptions: --load-restrictor LoadRestrictionsNone --enable-helm
```

### Cilium caveat

CSCS Seems to instrument the cluster with Cilium, which seems to automatically add extra fields to
Kubernetes resources. This confuses ArgoCD, thinking that the resources are OutOfSync. To remedy
this, we can simply exclude these resources from Argo. In the argocd-cm ConfigMap (argocd
namespace), we just need to add:

```yaml
resource.exclusions: |
    - apiGroups:
      - cilium.io
      kinds:
      - CiliumIdentity
      clusters:
      - "*"
```

## Install GitOps repo environment

Add the repo via web UI or CLI:

```bash
argocd repo add https://gitlab.com/ska-telescope/src/deployments/chsrc/ska-src-chsrc-services-cd.git --type git --project default --username argocd --password <gitlab_pat>
```

!!! Tip
    The GitLab PAT is generated in GitLab and can not be viewed after creation.
    Therefore we store it as a Secret in the `argocd` namespace with name `argocd-pat`.

To install the environment, `kubectly apply argocd-apps/<overlay>/main.yaml` to start the installation of all apps for a specific environment.