resource "google_logging_metric" "counter_metric" {
  name    = var.metric_name
  filter  = var.filter
  project = var.metric_project_id

  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
    dynamic "labels" {
      for_each = local.metric_labels
      content {
        key         = labels.value.key
        value_type  = labels.value.label_value_type
        description = labels.value.description
      }
    }
  }
  label_extractors = merge(flatten([local.extractors])...)

}

// Creating a dynamic map

locals {
  metric_labels = toset([
    for metric_label in var.labels : {
      key                = tostring(metric_label.key)
      label_value_type   = tostring(metric_label.label_value_type)
      description        = tostring(metric_label.description)
      extractor          = tostring(can(metric_label.regex) ? "REGEXP_EXTRACT" : "EXTRACT")
      regex              = tostring(try(metric_label.regex, ""))
      log_message_object = tostring(metric_label.log_message_object)
    }
  ])

  extractors = flatten(
    [for data in local.metric_labels :
      tomap(zipmap([data.key], data.extractor == "EXTRACT" ?
      ["${data.extractor}(${data.log_message_object})"] : ["${data.extractor}(${data.log_message_object}, \"${data.regex}\")"]))
    ]
  )
}

resource "time_sleep" "wait_for_metric" {
  create_duration = "15s"

  triggers = {
    # This sets up a proper dependency on the RAM association
    metric_id = google_logging_metric.counter_metric.id
  }
}
