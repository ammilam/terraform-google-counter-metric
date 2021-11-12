########################################
# Join Project To Google Metrics Scope #
########################################

data "google_client_config" "provider" {}

data "google_project" "monitored_project" {
  for_each   = toset(var.monitored_projects)
  project_id = each.key
}


data "google_project" "metrics_scope_project" {
  project_id = var.metrics_scope_project
}

# local exec used to join project(s) passed into a program's shared metrics scope
resource "null_resource" "join_metrics_scope" {
  for_each = data.google_project.monitored_project
  provisioner "local-exec" {
    environment = {
      MONITORED_PROJECT_NUMBER     = each.value.number
      METRICS_SCOPE_PROJECT_NUMBER = data.google_project.metrics_scope_project.number
      ACCESS_TOKEN                 = data.google_client_config.provider.access_token
    }
    command = <<-E0F
      set -e
      set -u

      # # delcares a function to join a project to a program's shared metrics scope
      joinMetricsScope(){
      curl -H "Authorization: Bearer $ACCESS_TOKEN" \
        -H "Content-Type: application/json" -X POST \
        -d "{'name': 'locations/global/metricsScopes/$METRICS_SCOPE_PROJECT_NUMBER/projects/$MONITORED_PROJECT_NUMBER'}" \
        https://monitoring.googleapis.com/v1/locations/global/metricsScopes/$METRICS_SCOPE_PROJECT_NUMBER/projects
        }

      # builds search variable for validation
      SEARCH="locations/global/metricsScopes/$METRICS_SCOPE_PROJECT_NUMBER/projects/$MONITORED_PROJECT_NUMBER"

      # creates a variable to check if a project is monitored as a part of a program's shared metrics scope
      validateScopeMembership=$(
      curl --silent -H "Authorization: Bearer $ACCESS_TOKEN" https://monitoring.googleapis.com/v1/locations/global/metricsScopes/$METRICS_SCOPE_PROJECT_NUMBER|
      jq '.monitoredProjects[]?'|
      jq --arg search "$SEARCH" 'select(.name == $search)'
      )

      CHECK=$(echo $validateScopeMembership|jq '.| select(.| .name)')

      if $(echo $validateScopeMembership|jq '.| select(.| .name)'); then
      JOIN="false"
      fi

      if ! $(echo $validateScopeMembership|jq '.| select(.| .name)'); then
      JOIN="true"
      fi

      # if the project is already a part of the program's monitoring scope, exit
      if [[ $JOIN == "false" ]]; then
        echo "Project is already joined to the metrics scope"
        exit 0
      fi

      # if it is not a project of the monitoring scope
      if [[ $JOIN == "true" ]]; then
        joinMetricsScope
        echo "Joining project to metrics scope"
      fi

    E0F
  }
}