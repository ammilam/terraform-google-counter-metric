variable "metric_project_id" {
  description = "project_id where the logs are"
  type        = string
}

variable "metric_type" {
  description = "type of logging metric, either counter or distribution"
  type        = string
  default     = "counter"
}

variable "labels" {
  description = "labels to extract from log message"
  type        = any
}

variable "metric_name" {
  description = "name of the logging metric name"
  type        = string
}

variable "filter" {
  description = "filter for the metric"
  type        = string
}