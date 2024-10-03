# Locked Credentials

If you add any type of credentials such as service accounts, IAM clients, service account tokens or
a mailing list/group, please add them to the documentation page in this wiki so that we can keep
track of them. Ideally we will set up any such resources in a way that they are shared among
admins/operators/developers as needed, but some of they may be tied to one persons account. Thus,
it's good to know whom to ask in case a credential expires or needs to be updated or changed. Please
also try to keep this list updated with best effort in case any of the resources are deleted or
deprecated.

| Secret in Vault                             | Service/App       | Owner    | Comment                                |
|---------------------------------------------|-------------------|----------|----------------------------------------|
| app/external-dns.gandi-externaldns-key      | external-dns      | Pablo    | Gandi's API key (deprecated). Can only be regenerated, not viewed. skach > account > authorized apps      |
| argocd-cm ConfigMap (argocd ns)             | ArgoCD dev        | Pablo    | OIDC client id and secret
| argocd-cm ConfigMap (argocd ns)             | ArgoCD prod       | Pablo    | OIDC client id and secret
