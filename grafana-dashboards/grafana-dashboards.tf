

# creates a grafana dashboard for each of the json dashboard exports under /dashboards
resource "kubernetes_config_map" "grafana_dashboards" {
  for_each = fileset(var.grafana_dashboards_directory, "*.json")
  metadata {
    name      = trimsuffix(each.key, ".json")
    namespace = var.monitoring_namespace
    labels = {
      (var.grafana_dashboard_label) = "1"
    }
  }

  data = {
    (each.key) = file("${var.grafana_dashboards_directory}/${each.key}")
  }
}