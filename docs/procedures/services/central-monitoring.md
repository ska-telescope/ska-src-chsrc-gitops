# Central Monitoring

Procedures related to the Central Monitoring service.

## Upgrading Prometheus

Helm doesn't really [deal with CRDs very well](https://helm.sh/docs/chart_best_practices/custom_resource_definitions/#some-caveats-and-explanations).
It will install them, but won't upgrade or uninstall.

When upgrading Prometheus, one therefore needs to manually upgrade CRDs according to the [documentation](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack#upgrading-chart).

## Reloading Prometheus Config

If the Prometheus config (such as scraping targets) are not being updated automatically after merging, please check the following:

### Check whether the prometheus pod contains the expected configuration.

```
kubectl get secret prometheus-kube-prometheus-stack-prometheus -n monitoring -o jsonpath='{.data.prometheus\.yaml\.gz}' | base64 -d | gunzip
```

### Try to force a reload of the prometheus config. This will often reveal a syntax error in the Prometheus configuration that needs fixing.

```
kubectl port-forward svc/kube-prometheus-stack-prometheus -n monitoring 9090:9090
```

And after the port-forward to the prometheus service/pod is successful (this example demonstrates an output where the config can not be reloaded):

```
$ curl -X POST http://localhost:9090/-/reload
failed to reload config: couldn't load configuration (--config.file="/etc/prometheus/config_out/prometheus.env.yaml"): parsing YAML file /etc/prometheus/config_out/prometheus.env.yaml: yaml: unmarshal errors:
  line 1501: cannot unmarshal !!str `https:/...` into []string
```

## Adding your SRC Site Service to Central Monitoring

A guide on how to add your SRC Site Services to central monitoring can be found [here](https://ska-telescope.gitlab.io/src/kb/ska-src-docs-operator/services/global/central-monitoring/add-service-endpoints.html).