# SKA CHSRC Gitops
This repository contains the GitOps configuration for CHSRC. It is based on [ArgoCD](https://argo-cd.readthedocs.io/en/stable/) and connected to a development Kubernetes cluster. As future development it is planned to implement [Kustomize overlays](https://argo-cd.readthedocs.io/en/stable/user-guide/kustomize/) for managing development and production environments in two separate Kubernetes clusters.

The repository will contain the manifests necessary to deploy the CHSRC infrastructure, currently applications are still being added.

[TOC]

## Using this repository
This repository reflects the CHSRC GitOps setup. If you want to replicate a similar setup, feel free to use the manifests herein as a base. It is constantly evolving, so please contact the Chocolate team to get the most recent Kubernetes prerequisites, context, and explanations for how to get the most out of this repo.

## Contributing
To contribute to this repository, please clone the repository and create a branch with a name that reflects what you are adding, for example by referring to a JIRA ticket (`choc-123-add-ci-pipeline`). Then follow the below steps.

### Example application
To see an example of a simple application deployed with ArgoCD and fetching secrets using the External Secrets Operator and Vault, please see the [http-echo](applications/http-echo) directory.

### Adding a new application with a Helm chart
- Add an `Application` ArgoCD resource for the application you want to add. You can use the [http-echo](applications/http-echo.yaml) app as an example. The `Application` manifests are in the [applications](applications) directory.
- Ensure that you name your `Application` resource file using the application name for clarity (e.g. `vault.yaml`).
- Edit the `Application` resource as needed, for example, set the Helm chart repo and version to the one you wish to use. If you are working on a branch, you should point to the branch.
- Merge the `Application` manifest to `main`.
    - TODO: Discuss if there is a better way to do this, to avoid having to edit `main` before starting to develop.
- You can continue working in your branch and adding manifests as needed (`values.yaml` for the chart, secrets, certificate...) and see them getting deployed from your branch into the development cluster.
- When you are finished, and the application works as expected, create a merge request to add your work to `main`.
- When the application directory and manifests are merged to `main`, update the original `Application` resource to point to `main` and delete the branch you were using if you don't need it anymore.

### Adding manifests
- These instructions are for adding manifest in case they are not part of a Helm chart (e.g. a `Deployment.yaml`, service account, a certificate...)
- If you are adding a manifest to an existing directory, simply add the manifest (`*.yaml` file) in the application directory (e.g. `vault/deployment.yaml`).
- To add single manifests, if the application doesn't exist yet, you will always need to add an `Application` ArgoCD resource and a directory where the manifests will be stored. Name the `Application` yaml file and directory using your application name (e.g. `vault.yaml` and `vault`).
- When adding manifests (without a Helm chart) you need an application as follows. Please edit `metadata.name`, `spec.sources.targetRevision` ,`spec.sources.path` and `spec.destination.namespace` as needed:
```
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: application-name-here
  namespace: argocd
spec:
  project: default
  sources:
  - repoURL: https://gitlab.com/ska-telescope/src/ska-chsrc-gitops.git
    targetRevision: main
    ref: argorepo
    path: applications/application-name-here
    directory:
      exclude: 'values.yaml'
  destination:
    server: https://kubernetes.default.svc
    namespace: namespace-the-resources-go-into
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
```
- When you are finished editing, create a merge requests to the `main` branch. If you want to keep developing on a branch, point to it using `targetRevision` in the `Application` manifest. Note that nothing will be deployed from a development branch if you don't have an `Application` in the `main` branch that points to your development branch.
- When you have merged to `main`, you can either keep developing on your branch if you were using one, or clean up the `main` branch if you are finished. To clean up, remember to edit the `targetRevision` in the `Application` in `main` if you were using a branch and to delete your development branch if you don't need it anymore.

### Merging your branch
When you are ready to submit your work, create a merge request for main and assign someone from the Chocolate team to review your contribution.

### CI pipeline
At the moment we are using a simple CI pipeline based on [kubeconform](https://github.com/yannh/kubeconform) to lint the manifests we deploy. The pipeline may be further enhanced in the future with additional tools to ensure a good quality and correctness.

### FAQ and notes
-  Note that nothing will be deployed from a development branch if you don't have an `Application` in the `main` branch that points to your development branch. See [Contributing](#contributing) for details.

## Contact
The code is managed by the Chocolate team :chocolate_bar: within SRCNet.