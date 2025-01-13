# Alerting
This page describes the current alerting setup for CHSRC.

[TOC]

# Alertmanager alerts
This section describes how to create an Alertmanager alert for a Prometheus
metric and sending the alerts to Slack.

## Adding a new alert with notifications
Adding a new alert and sending notifications to a Slack channel requires some
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

!!! Tip "Routing alerts"
    Note that the same alert can be routed to multiple slack channels, for
    example, a national channel and a shared SRCNet channel. This is helpful for
    sharing or filtering the alerts as needed.

The alerts can be customized to contain links to dashboards, emojis, links to
documentation for how to resolve a type of alert etc. It is also possible to
send a customized message when the alerting metric has recovered.

![](../../images/alerting/recovering-alert.png)


# Configuring Slack integration
The Slack integration is set up using an Incoming Webhook that is defined in the
Slack instance itself in Automations -> Apps -> Incoming Webhooks.

![](../../images/alerting/slack-webhook.png)

Adding a new webhook generates a URL that is stored as a secret in Vault
(apps/alertmanager). The secret is mounted in the alertmanager instance and referred to using
`alertmanager.config.global.slack_api_url_file`.

## Editing an existing webhook
The existing webhook can be edited in the Incoming Webhooks configuration menu.

![](../../images/alerting/configure-webhook.png)

## How to regenerate the slack-api-url
!!! Tip "Ownership of the webhook"
    Note that only the owner of the webhook can edit it and manage the Slack API
    URL link, as well as the channel to which the alert is sent. This is not
    transferrable. If the ownership needs to be moved, it is necessary to create
    a new webhook and update the slack-api-url secret accordingly in Vault.

You can list all the webhooks in the slack instance, but only the ones you own
are editable. The `slack-api-url` can be regenerated when you edit the webhook.
If it is regenerated the old link will stop working and alerts will not be sent
until the credential has been updated in Vault and Alertmanager has picked up
the changed secret.
![](../../images/alerting/edit-webhook.png)
