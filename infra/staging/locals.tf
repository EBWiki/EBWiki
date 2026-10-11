locals {
  railway_project_name = "ebwiki-maps-preview"
  railway_service_name = "ebwiki-web"

  railway_environment_import_id    = "${var.railway_project_id}:${var.railway_environment_name}"
  railway_service_domain_import_id = "${var.railway_service_id}:${var.railway_environment_name}:${var.railway_service_domain_fqdn}"
}
