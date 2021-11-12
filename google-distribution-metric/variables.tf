variable "metric_project_id" {
  description = "project_id where the logs are"
  type        = string
}

variable "metric_kind" {
  description = "(Required) Whether the metric records instantaneous values, changes to a value, etc. Some combinations of metricKind and valueType might not be supported. For counter metrics, set this to DELTA. Possible values are DELTA, GAUGE, and CUMULATIVE"
  type        = string
  default     = "DELTA"
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

variable "value_log_message_object" {
  type        = string
  description = "log message object to parse value from for a distribution metric"
}

variable "value_regex" {
  type        = string
  description = "(optional) regex used to parse out value mapping"
  default     = ""
}

variable "unit" {
  type        = string
  description = "The unit in which the metric value is reported. It is only applicable if the valueType is INT64, DOUBLE, or DISTRIBUTION. The supported units are a subset of The Unified Code for Units of Measure standard"
}

variable "num_finite_buckets" {
  type        = number
  description = "The total number of finite buckets. The value must be greater than 0."
  default     = 12
}

variable "growth_factor" {
  type        = number
  description = "The exponential growth factor for the buckets. The value must be greater than 1."
  default     = 2
}

variable "scale" {
  type        = number
  description = "The linear scale for the buckets. The value must be greater than 0."
  default     = 1
}
