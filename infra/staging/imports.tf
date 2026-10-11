import {
  to = railway_project.ebwiki
  id = var.railway_project_id
}

import {
  to = railway_environment.production
  id = local.railway_environment_import_id
}

import {
  to = railway_service.ebwiki
  id = var.railway_service_id
}

import {
  to = railway_service_domain.public
  id = local.railway_service_domain_import_id
}

import {
  to = cloudflare_dns_record.legacy_staging_ebwiki
  id = "${var.cloudflare_zone_id}/${var.cloudflare_staging_dns_record_id}"
}
