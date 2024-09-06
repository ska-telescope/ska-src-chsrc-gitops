# Introduction

![](images/chocolate_computer.jpg){: style="width:40%;" .shadow; align=right}

This documentation should help answer the questions of why the project is organised in a certain
way, as well as showing by example how to perform common procedures on our infrastructure. Some of
these may be specific to CHSRC, but some could easily be reused elsewhere.

## Design Goals

The deployment of applications on Kubernetes-based Infrastructure can be done in many different
ways. Especially when taking into account that we have more than one cluster (e.g. dev and prod),
this enables quite a few permutations and options with different trade-offs. Our setup has the
following design goals:

- **Infastructure as Code and automation**. We want to be able to deploy applications in a
  declarative way, with changes expressed as code that can be reviewed and rolled back, as well as
  leveraging git workflows such as feature branches for development. In short, enabling the use of
  well known software engineering practices, applied to infrastructure.
- **A single repo**. A single repo approach simplifies the upgrades and deployments within each
  cluster, since otherwise changes that span across repos would have to be carefully synchronised
  (merged in the right order, etc).
- **Environments**. Ability to have at least a _dev_ environment and a _prod_ environment. Having
  more than one environment enables us to evaluate the infrastructure with all the applications
  working together on the same environment, ahead of releasing to production. Ideally, not just with
  short lived-environments, but also in long-lived environments which allow us to actually use and
  smoke test the infrastructure.
- **Mergeable environment branches**. Being able to merge the _dev_ branch into _prod_ minimises
  typos or copy-paste errors that would arise if we had two completely independent environment
  branches that we couldn't merge into each other.
- **Feature branches**. Developers are able to work in an independent git branch that tracks the
  development of a new change or feature.
- **Secrets are handled by a secret store**. Secrets are therefore not committed into the
  repository, and we still keep a single source of truth. We exclude solutions such as SOPS, as they
  push secrets (even if in encrypted form) to our public git repo.

## Assumptions

We get a Kubernetes platform from our provider, and as part of the validation, some applications are
pre-installed. Therefore, we assume that the following is already present:

* ingress-nginx (namespace `ingress-nginx`)
* External Secrets Operator (namespace `external-secrets`)
* letsencrypt-issuer for nginx
* cert-manager (namespace `cert-manager`)
* external-dns (namespace `external-dns`). We install our own `skach-external-dns`.

As a result, these applications and operators are not part of our gitops repo. We do install our own
external-dns in the `skach-external-dns` namespace to work with our own DNS provider.