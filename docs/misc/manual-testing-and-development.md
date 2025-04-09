# Manual testing and development

Note that in general, manual testing should only be done in the dev cluster, and it is preferred to follow the
[GitOps procedures](../procedures/gitops/new-app.md) as far as possible. Any manual testing should also be cleaned up after the testing is finished. However, if manual testing is needed, please take the below points into account.

## Namespaces
When creating a namespace manually with `kubectl` or using `helm install`, you need an annotation. Please see below for examples. If you do not add this annotation you will not be able to access the namespace or use it.

### Dev environment
```
apiVersion: v1
kind: Namespace
metadata:
  name: my-namespace-dev
  annotations:
    field.cattle.io/projectId: c-m-87s92m9v:p-qvdqp
```

### Prod environment
```
apiVersion: v1
kind: Namespace
metadata:
  name: my-namespace-prod
  annotations:
    field.cattle.io/projectId: c-m-g4gg2jck:p-z6jsk
```