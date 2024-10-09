# Central Monitoring

Procedures related to the Central Monitoring service.

## Upgrading Prometheus

Helm doesn't really [deal with CRDs very well](https://helm.sh/docs/chart_best_practices/custom_resource_definitions/#some-caveats-and-explanations).
It will install them, but won't upgrade or uninstall.

When upgrading Prometheus, one therefore needs to manually upgrade CRDs according to the [documentation](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack#upgrading-chart).

## Adding your SRC Site Service to Central Monitoring

TODO