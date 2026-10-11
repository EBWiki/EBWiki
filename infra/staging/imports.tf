import {
  to = railway_project.ebwiki_maps_preview
  id = var.railway_project_id
}

import {
  to = railway_environment.production
  id = local.railway_environment_import_id
}

import {
  to = railway_service.ebwiki_web
  id = var.railway_service_id
}

import {
  to = railway_service_domain.public
  id = local.railway_service_domain_import_id
}
