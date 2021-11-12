variable "monitored_projects" {
  type        = list(string)
  description = "Project being monitored via a metrics scope. Should specify the project id containing resources to be monitored."
}

variable "metrics_scope_project" {
  type        = string
  description = "Project id that has the shared metrics scope that the monitored project joins. Created via the monitoring module."
}