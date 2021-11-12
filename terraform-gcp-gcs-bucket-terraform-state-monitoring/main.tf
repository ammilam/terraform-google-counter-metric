
data "archive_file" "terraform_state_monitoring" {
  type        = "zip"
  source_dir  = "${path.module}/function"
  output_path = "${path.module}/files/index.zip"
}

resource "google_storage_bucket" "terraform_state_monitoring" {
  name                        = "terraform-state-monitoring-cf-${var.project_id}-${var.suffix}"
  project                     = var.project_id
  uniform_bucket_level_access = true
  force_destroy               = true
}

# # uploads ecc zip to storage bucket
resource "google_storage_bucket_object" "terraform_state_monitoring" {
  name   = "function/index-${data.archive_file.terraform_state_monitoring.output_md5}.zip"
  bucket = google_storage_bucket.terraform_state_monitoring.name
  source = data.archive_file.terraform_state_monitoring.output_path
}


resource "google_cloudfunctions_function" "terraform_state_monitoring" {
  name                  = "terraform-state-monitoring-${var.suffix}"
  description           = "Cloud function that monitors terraform remote state"
  runtime               = "nodejs14"
  project               = var.project_id
  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.terraform_state_monitoring.name
  source_archive_object = google_storage_bucket_object.terraform_state_monitoring.name
  timeout               = 60
  entry_point           = "state"
  region                = var.region
  max_instances         = 50
  event_trigger {
    event_type = "google.storage.object.finalize"
    resource   = var.bucket
  }
  environment_variables = {
    bucket = var.bucket
  }
}
