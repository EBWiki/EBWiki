resource "railway_project" "ebwiki_maps_preview" {
  name = local.railway_project_name

  lifecycle {
    prevent_destroy = true
  }
}

resource "railway_environment" "production" {
  name       = var.railway_environment_name
  project_id = railway_project.ebwiki_maps_preview.id

  lifecycle {
    prevent_destroy = true
  }
}

resource "railway_service" "ebwiki_web" {
  name       = local.railway_service_name
  project_id = railway_project.ebwiki_maps_preview.id

  source_repo        = var.github_repo
  source_repo_branch = var.github_branch
  config_path        = var.railway_config_path

  lifecycle {
    prevent_destroy = true
  }
}

resource "railway_service_domain" "public" {
  service_id     = railway_service.ebwiki_web.id
  environment_id = railway_environment.production.id
  subdomain      = split(".", var.railway_service_domain_fqdn)[0]

  lifecycle {
    prevent_destroy = true
  }
}

resource "railway_custom_domain" "staging" {
  domain         = var.staging_hostname
  service_id     = railway_service.ebwiki_web.id
  environment_id = railway_environment.production.id
}
