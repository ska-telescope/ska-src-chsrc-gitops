# SKA CHSRC Gitops

This repository contains the GitOps configuration for CHSRC. It is based on [ArgoCD](https://argo-cd.readthedocs.io/en/stable/) and connected to a development Kubernetes cluster. As future development it is planned to implement [Kustomize overlays](https://argo-cd.readthedocs.io/en/stable/user-guide/kustomize/) for managing development and production environments in two separate Kubernetes clusters.

The repository will contain the manifests necessary to deploy the CHSRC infrastructure, currently applications are still being added.

[TOC]

## Using this repository and docs

This repository reflects the CHSRC GitOps setup. If you want to replicate a similar setup, feel free to use the manifests herein as a base. It is constantly evolving, so please contact the Chocolate team to get the most recent Kubernetes prerequisites, context, and explanations for how to get the most out of this repo.

You can find documentation related to this repo the rendered `docs/` from this directory [here](http://docs.dev.skach.org/) (dev) or [here](http://docs.src.skach.org/) (prod).

## Contributing

See the `Making changes` Section in the docs.

### CI pipeline

At the moment we are using a simple CI pipeline based on [kubeconform](https://github.com/yannh/kubeconform) to lint the manifests we deploy.

We also automatically generate the docs and publish them on GitLab Pages.

The pipeline may be further enhanced in the future with additional tools to ensure a good quality and correctness.

## Contact

The code is managed by the Chocolate team :chocolate_bar: within SRCNet.
