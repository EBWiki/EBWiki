locals {
  railway_project_name = "ebwiki"
  railway_service_name = "ebwiki"

  railway_environment_import_id    = "${var.railway_project_id}:${var.railway_environment_name}"
  railway_service_domain_import_id = "${var.railway_service_id}:${var.railway_environment_name}:${var.railway_service_domain_fqdn}"
  railway_custom_domain_import_id  = "${var.railway_service_id}:${var.railway_environment_name}:${var.staging_hostname}"
}
