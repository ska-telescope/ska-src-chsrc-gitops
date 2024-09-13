# Adding a new app

## Quickstart 🚀 

When adding a new app, start on a development branch in the dev cluster.

You can just take an existing application as template. Take for example the sample *http-echo*
application. This is a very simple application meant for learning, validation, and testing, which
includes using it as a starting point/template.

Applications will have a directory structure roughly resembling the following:

```
.
├── apps
│   └── app1
│       ├── base
│       │   ├── kustomization.yaml
│       │   ├── resourceX.yaml
│       │   ├── resourceY.yaml
│       │   └── values.yaml
│       └── overlays
│           ├── dev
│           │   ├── kustomization.yaml
│           │   ├── resourceX.yaml
│           │   └── values.yaml
│           └── prod
│               ├── kustomization.yaml
│               ├── resourceX.yaml
│               └── values.yaml
└── argocd-apps
    ├── dev
    │   └── app1.yaml
    └── prod
        └── app1.yaml
```

This would represent an app, `app1`, that's deployed across two clusters/environments (dev and
prod), and which leverages Kustomize to minimise duplication of resources.

The `apps/app1/base` directory would contain the resources that all clusters/environments have in
common, while in the overlays we would only specify patches for environment-specific values. The
`argocd-apps` directory contains ArgoCD specific resources, while the `apps` directory contains
mostly ArgoCD-agnostic Kubernetes resources. This clean split enables reusability of resources.

As mentioned, a **good starting point** would be to just **take an existing app as template** and
just changing the relevant properties.

The values to change in the template should be evident or self-explanatory. but just in case, here's
a checklist of properties that you will probably want to modify when basing a new application off a
template:

* The `argocd-apps/<environment>/app1.yaml` file name should match the application's (short) name.
  * For the same file, the ArgoCD `Application`'s `metadata.name` ideally will match the name of the
    yaml file.
  * Leave the `namespace: argocd` which points to our default project.
  * For the same file, under `spec.sources[0].path`, point to the directory where this application's
    overlay lives.
  * targetRevision (e.g. branch name such as `dev`) to track.
* A directory under `apps/` named the same as the application's yaml filename above, that contains a
  typical kustomization structure.
  * A `base` subdirectory which contains a `kustomization.yaml` and application-specific resources.
    For instance, the values.yaml file for helm charts. Make sure that this kustomization specifies
    all used base resources under `resources`, not including the Helm values.yaml file.
  * An `overlays/<environment>` directory which contains a `kustomization.yaml` file and
    environment-specific patches that differ from the base resources.

The **overlay's kustomization.yaml** file will be the entry point for installing the application.
Therefore, please define the following if needed:

* The namespace, ideally matching the application's short name, directory name, and ArgoCD
  `Application` name.
* If the application deploys an external helm chart, set at least:
  * Helm repo url in `repo`.
  * Chart name in `name`.
  * Give a specific `version`. While this is an optional field, we want to be explicit for which
    version we're running. This makes upgrades and rollbacks easier, so always make sure to include
    a revision/version.
  * `namespace`: will usually match the application's namespace.
  * `helmCharts[].valuesFile` should reference the values.yaml file in the app's **base** directory.
  * `helmCharts[].additionalValuesFile` should reference the values.yaml file in the app's
    **overlay**. Helm will apply a strategic merge patch, with this file's values overriding the
    base valuesFile.
* If the application deploys regular Kubernetes resources:
  * The base directory will contain those resources that are common to both overlays/environments.
    It should reference `../../base` under `resources`.
  * Each overlay that contains environment-specific patches can have those applied by listing them
    under `patches`.
    * Patches can either be JSON patches, or strategic merge patches.
    * Take into account that **strategic merge patches do not merge lists**. Lists are always
      overwritten by the patch.
    * Please name JSON patches as `<name>-patch.yaml` in order to pass the CI.
    * Prefer strategic merge patches or JSON patches based on common sense about what is simpler,
      according to each case.

## Secrets 🪅

See the [Secrets Management](app-secrets.md) doc.

## Branching 🌳

See [Making Changes](making-changes.md) for how to deal with feature branches and MRs. Adding a new app is just a
special case for making a change to the infrastructure.

## Locked Credentials 🗝️

If you add any type of credentials that are somehow tied to your account and not shared with the
team, see the [Locked Credentials](../../misc/locked-credentials.md) doc.