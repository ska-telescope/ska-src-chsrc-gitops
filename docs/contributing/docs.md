# Contributing to the docs

These docs live in the git repository, so please check how to [contribute to the repo](repo.md), as
it will have to follow the same procedure.

However there are some additional tips and tricks that are specific to the docs.

## Local preview

Install and previewing the docs locally is quite easy and practical. If it's the first time you are
setting up, install the environment. The following assumes that you're at the **root of the
repository**.

```bash
python3 -m venv venv
source venv/bin/activate
pip install mkdocs mkdocs-material mkdocs-glightbox mkdocs-literate-nav mkdocs-git-revision-date-localized-plugin
mkdocs serve --watch-theme
```

This should bring up a local instance of mkdocs running locally, and that automatically reloads any
changes.

## Remote preview

You can also get a live preview. This can be especially **useful for reviewers** as they do not need
to even setup a local installation configured on the MR's branch.

Once changes are pushed to a branch, you will get a live preview of this branch at
*https://ska-telescope.gitlab.io/src/deployments/chsrc/ska-src-chsrc-services-cd/<branch_name\>*.

So just substitute with the branch specified in the MR, and you will see the changes live!