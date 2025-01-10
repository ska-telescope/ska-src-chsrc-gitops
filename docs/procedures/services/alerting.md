# Alerting
This page describes the current alerting setup for CHSRC.

# Alertmanager alerts
This section describes how to create an Alertmanager alert for a Prometheus
metric and sending the alerts to Slack.

## Adding a new alert with notifications
To add a new alert and send notifications to a Slack channel requires some
configuration both in Prometheus and in Alertmanager.

### Prometheus configuration
To add a new alert, you need to decide which metric and which value it will react
on. The alerts are added to the Prometheus configuration as [alerting rules](https://prometheus.io/docs/prometheus/latest/configuration/alerting_rules/)
under `additionalPrometheusRulesMap` in the `values.yaml`.

### Alertmanager configuration
When the alert is added to Prometheus you can set up routing for this alert in
alertmanager. This is configured in the `alertmanager.config.route` section. The
routing can route an alert that matches specific labels to a specific receiver.
The receiver is set up in the `alertmanager.config.receivers` section. In the
receiver you can customize where the alert will be sent (e.g. a slack channel),
which credentials to use, and the layout of the message that will be sent.

See the documentation for more details and settings for routing and receivers:

- [Routing configuration](https://prometheus.io/docs/alerting/latest/configuration/#route-related-settings)  
- [Reveiver configuration](https://prometheus.io/docs/alerting/latest/configuration/#general-receiver-related-settings)  

## Configuring Slack integration
The Slack integration is set up using an Incoming Webhook that is defined in the
Slack instance itself in Automations -> Apps -> Incoming Webhooks. Adding a new
webhook generates a URL that is stored as a secret in Vault (apps/alertmanager).
The secret is mounted in the alertmanager instance and referred to using
`alertmanager.config.global.slack_api_url_file`.