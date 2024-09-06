# Deleting an app

To delete an application, remove it from git. During the next sync, ArgoCD will delete it.

Specifically, take into account the following caveats:

* Argo will allow you to use the web UI and CLI to delete an app, but this will not work (see below why).
* Similarly, using kubectl to delete the `Application` resource will not work (see below why).

The issue is that in our case, the `Application` is defined in the git repo, and therefore ArgoCD will immediatelly recreate it.
There is a trade-off here, as we could choose to add/remove the apps through the CLI/Web interfaces instead of
adding them on git, but in this case we would lose the ability of having them versioned controlled
(See [Design Goals](../../index.md#design-goals)).