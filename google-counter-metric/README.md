# Counter Google Logging Metric Module

This folder contains the Counter Google Logging Metric module. For information on google logging metrics, refer to the following [documentation](https://cloud.google.com/logging/docs/logs-based-metrics).

This module is intended to simplify the counter logging metric resource creation via terraform. Documentation on the actual terraform resource definition can be found [here](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/logging_metric).

This README contains templates that can be copied, modified, and used to implement Counter Google Logging Metrics for any GCP projects and the resources contained therein. Information on the variables accepted by the alerting module can be found within [variables.tf](/modules/counter-metric/variables.tf). Using this module outputs the id of the google logging metric as `counter_metric_id` to be used with custom logging metrics. [See below for an example]()...

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
  source            = "git::https://gitlab.gcp.company.com/shared-services/monitoring.git//modules/counter-metric?ref=<most-recent-tag>"
  metric_project_id = "" # project_id for the logging metric
  metric_name       = "" # metric name
  filter            = "" # filter for the logging metric
  labels = [
    {
      key                = "" # (required) label_key, must be one word with no spaces
      label_value_type   = "" # (optional) data type of the label: defaults to STRING
      description        = "" # (required) description of the label
      log_message_object = "" # (required) object where logs are written: jsonPayload.message, textPayload
      regex              = "" # (optional) single group regex pattern
    },
  ]
}

```

### Example Counter Metric Implementation

```terraform
############################################################################
# This creates a custom logging metric using the counter-metric module.    #
# Google logging metrics allow for the creation of something more dynamic  #
# and useful than regular log files. Once custom logging metrics exist,    #
# they can be used for alert policies, data pipelines, dashboards, on-prem #
# routing, and much more!                                                  #
############################################################################

############################################################################
# The purpose of this particular logging metric is to show what user is    #
# performing a particular action on a given resource                       #
############################################################################
module "example_metric" {
  source            = ""git::https://gitlab.gcp.company.com/shared-services/monitoring.git//modules/counter-metric?ref=<most-recent-tag>"
  metric_project_id = "test"                                                       # project_id for the logging metric
  metric_name       = "user-invoked-method"                                                 # metric name
  filter            = "protoPayload.authenticationInfo.principalEmail=~\"(.*)@company.com\"" # filter for the logging metric
  labels = [
    {
      key                = "email"                                          # creates email label
      label_value_type   = "STRING"                                         # sets data type of the label
      description        = "email address from data access log"             # sets description of the label
      log_message_object = "protoPayload.authenticationInfo.principalEmail" # object where logs are written
    },
    {
      key                = "parsed_method"  # creates parsed_method label to extract value from the methodName string using regex
      label_value_type   = "STRING"         # sets data type of the label
      description        = "parsed method"  # sets description of the label
      regex              = "([^.]+$)"
      log_message_object = "protoPayload.methodName" # object where logs are written
    },
    {
      key                = "resource_name"                       # creates resource_name label
      label_value_type   = "STRING"                              # sets data type of the label
      description        = "name of the resource being modified" # sets description of the label
      log_message_object = "protoPayload.resourceName"           # object where logs are written
    },
    {
      key                = "google_service_name"        # creates google_service_name label
      label_value_type   = "STRING"                     # sets data type of the label
      description        = "name of the google service" # sets description of the label
      log_message_object = "protoPayload.serviceName"   # object where logs are written
    }
  ]
}
```

### Using Counter Metric In Alert Policy

The counter metric module has an output called `counter_metric_id` that outputs the name of the logging metric. Below is an example alert policy that references the example metric above. TLDR: `metric.type=\"logging.googleapis.com/user/${module.example_metric.counter_metric_id}\"`

```terraform
module "logging_metric_demo_alert" {
  source                       = "git::https://gitlab.gcp.company.com/shared-services/monitoring.git//modules/alerting?ref=v2.1.0"
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
      filter                 = "metric.type=\"logging.googleapis.com/user/${module.example_metric.counter_metric_id}\" resource.type=\"audited_resource\"" # filter for alert policy
      condition_display_name = "Project Resource Accessed"                                                                                              # name for threshold condition
    },
  ]
}
```
