# Making changes to an app

## Introduction

Making changes to an application is a fundamental aspect of infrastructure lifecycle. It is
necessary for making improvements, fixing security issues and bugs, and keeping software up-to-date.
However, making changes also comes with certain difficulties and risk. Therefore, it is important to
follow a methodical approach to making changes in a controlled and consistent way.

In general (excepting extremely urgent hotfixes), one should deploy any changes to the dev cluster
first, and verify that the application is working correctly before it's rolled out to production.

## Making changes to an ArgoCD Application

![building blocks](../../images/chocolate_blocks.jpg){: style="width:40%;" align=right}

The main entry-point for Argo on a given cluster will usually a track branch with the same name as
the cluster. For the prod cluster, this would be the prod branch, while for the dev cluster, this
would be the dev branch.

The entry-point application then simply points to additional applications to be deployed. Each of
these applications can then reference a different branch of the repo. We can make use of the
isolation provided by git branches in order to work on different features simultaneously. Therefore,
for making a change, we can start by creating a feature branch on the development cluster first, and
then merging it back after a review.


More specifically, the workflow is as follows.

### Workflow

!!! Warn
    If the service changes will have a visible impact on other users (either end-users, or
    services operators that depend on the service undergoing changes), one should announce the planned
    change or intervention to end users with sufficient time to adapt for this change. This is obviously
    less important during prototyping, but keep in mind the impact of changes on the network.

**On the dev cluster** Create a feature branch, and push the branch (even if there are no new
commits). Try to give this branch name a descriptive name, including the related task ticket if
possible. For example:

```bash
git switch -c choc-5-new-feature
git push origin choc-5-new-feature
```

Back on the development branch, switch the application to the relevant feature branch. 

```bash
git switch development
```

For instance, you would change the repoURL reference from:

```yaml
- repoURL: git@gitlab.com:ska-telescope/src/deployments/chsrc/ska-src-chsrc-services-cd.git
  targetRevision: dev
  ref: argorepo
  path: apps/myapp/overlays/dev
```

to your new feature branch:

```yaml
- repoURL: git@gitlab.com:ska-telescope/src/deployments/chsrc/ska-src-chsrc-services-cd.git
  targetRevision: choc-5-new-feature
  ref: argorepo
  path: apps/myapp/overlays/dev
```

As soon as this changes are pushed into the remote's development branch, any changes you push into
the choc-5-new-feature will go live. That's why we pushed the branch before pushing the change.

Once the feature is considered ready, open a Merge Request. If the MR needs to undergo review, new
changes can be pushed to the feature branch. When merging, squash or rebase as needed to keep a
clean git history: ideally one feature equals one commit. The goal is to make any necessary
rollbacks easy in an isolated fashion (i.e. rolling back one feature = rolling back one commit).

Once merged into the development branch, it is recommended to keep the new change for a week or two
in order to detect any unexpected behaviours or bugs.

!!! Tip
    If the changes have an impact on end-users, there might be a chance for end-users to
    evaluate on the development deployment.

### Merging dev to prod

When the changes are ready to go into production, one can simply create a Merge Request from
dev to prod. It should undergo review just like any other merge request, with special
attention to the potential impact that these changes might have on the production system.

!!! Note
    This might merge more than one feature: it merges the development environment into
    production. It is therefore recommended to merge from development to production often, to keep
    the changes small and under control.