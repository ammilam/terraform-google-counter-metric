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