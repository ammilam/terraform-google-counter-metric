variable "monitoring_namespace" {
  type        = string
  description = "Namespace that kube-prometheus-stack is deployed into"
}

variable "prom_stack_common_label" {
  type        = string
  default     = "default"
  description = "label added to all resources created via kube-prometheus-stack helm chart, helps with prometheus rule ingestion"
}

variable "grafana_dashboard_label" {
  type        = string
  default     = "grafana_dashboard"
  description = "label used to provision a grafana dashbaord"
}

variable "grafana_dashboards_directory" {
  type        = string
  default     = ""
  description = "location of the directory containing the grafana dashboards"
}