# distribution Google Logging Metric Module

This folder contains the Distribution Google Logging Metric module. For information on google logging metrics, refer to the following [documentation](https://cloud.google.com/logging/docs/logs-based-metrics).

This module is intended to simplify the distribution logging metric resource creation via terraform. Documentation on the actual terraform resource definition can be found [here](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/logging_metric).

This README contains templates that can be copied, modified, and used to implement distribution Google Logging Metrics for any GCP projects and the resources contained therein. Information on the variables accepted by the alerting module can be found within [variables.tf](/modules/distribution-metric/variables.tf). Using this module outputs the id of the google logging metric as `distribution_metric_id` to be used with custom logging metrics. [See below for an example]()...

## Metric definition

Metrics can be defined with one or more `labels` placed under the `labels` definition. Each `label` is comprised of the following variables...

* `key` - (required) Name of the label, must be lowercase and contain no spaces
* `label_value_type` - (optional) Type of data contained in the label, defaults to STRING
* `description` - (required) Description for the label
* `log_message_object` - (required) object where logs are written
* `regex` - (optional) supports single group regex pattern for extracting data from the `log_message_object`

### Template Implementation

```terraform
module "metric" {
  source                   = "<source>"
  metric_project_id        = "" # (required) project_id for the logging metric
  metric_name              = "" # (required) metric name
  filter                   = "" # (required) filter for the logging metric
  value_log_message_object = "" # (required) for value mapping => object where logs are written: jsonPayload.message, textPayload
  value_regex              = "" # (optional) regex used to parse out value mapping
  metric_kind              = "" # (optional) DELTA, GAUGE, and CUMULATIVE
  unit                     = "" # (required) unit in which the metric value is reported
  labels = [
    {
      key                = "" # (required) label_key, must be one word with no spaces
      label_value_type   = "" # (optional) data type of the label: defaults to STRING
      description        = "" # (optional) description of the label
      log_message_object = "" # (required) object where logs are written: jsonPayload.message, textPayload
      regex              = "" # (optional) single group regex pattern
    },
  ]
}

```

### Example Distribution Metric Implementation

```terraform

# adds logging metric that creates metrics from billing insights data
# this metric allows for cost analysis of gcp projects

module "billing_metric" {
  source                   = "<source>"
  metric_name              =  "billing-insights"
  metric_project_id        = var.base_project_id
  filter                   = "resource.type=\"cloud_function\" jsonPayload.ppsid!=null"
  value_log_message_object = "jsonPayload.total_exact"
  metric_kind              = "CUMULATIVE"
  unit                     = "usd"
  labels = [
    {
      key                = "env"
      label_value_type   = "STRING"
      description        = "env label from gcp project"
      log_message_object = "jsonPayload.env"
    },
    {
      key                = "month"
      label_value_type   = "STRING"
      description        = "month label from gcp project"
      log_message_object = "jsonPayload.month"
    },
    {
      key                = "name"
      label_value_type   = "STRING"
      description        = "name label from gcp project"
      log_message_object = "jsonPayload.name"
    },
    {
      key                = "team"
      label_value_type   = "STRING"
      description        = "team label from gcp project"
      log_message_object = "jsonPayload.team"
    },
    {
      key                = "ppsid"
      label_value_type   = "STRING"
      description        = "ppsid label from gcp project"
      log_message_object = "jsonPayload.ppsid"
    },
  ]
}
```

### Using distribution Metric In Alert Policy

The distribution metric module has an output called `distribution_metric_id` that outputs the name of the logging metric. Below is an example alert policy that references the example metric above. TLDR: `metric.type=\"logging.googleapis.com/user/${module.example_metric.distribution_metric_id}\"`

```terraform
module "logging_metric_demo_alert" {
  source                       = "<source>"
  enabled                      = true
  application                  = "shared-services"
  channel_type                 = "google_chat" # sets the channel_type that is used to find the appropriate escalation path
  alert_route                  = "demo"    # specifies the actual route for the notification once a channel_type is set
  monitoring_project_id        = var.monitoring_project_id
  display_name                 = "I am a test alert and trigger when a resource is accessed" # policy display name
  pub_sub_notification_channel = var.channel
  content                      = "$${metric.label.email} has invoked $${metric.label.parsed_method} method in Project $${resource.project}"
  alert_conditions = [
    {
      duration               = "0s"                                                                                                                     # duration in seconds : 300s
      alignment_period       = "36000s"                                                                                                                 # alignment period in seconds : 900s
      group_by_fields        = ["resource.project_id", "metric.email", "metric.parsed_method"]                                                          # used for alert message creation : ["resource.project_id"]
      threshold_count        = 0                                                                                                                        # threshold_percent can be used as well : 0
      filter                 = "metric.type=\"logging.googleapis.com/user/${module.example_metric.distribution_metric_id}\" resource.type=\"audited_resource\"" # filter for alert policy
      condition_display_name = "Project Resource Accessed"                                                                                              # name for threshold condition
    },
  ]
}
```
