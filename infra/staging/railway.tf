resource "railway_project" "ebwiki" {
  name        = local.railway_project_name
  description = "HTTP-authed Rails preview of the EBWiki case map"

  lifecycle {
    prevent_destroy = true
  }
}

resource "railway_environment" "production" {
  name       = var.railway_environment_name
  project_id = railway_project.ebwiki.id

  lifecycle {
    prevent_destroy = true
  }
}

resource "railway_service" "ebwiki" {
  name       = local.railway_service_name
  project_id = railway_project.ebwiki.id

  source_repo        = var.github_repo
  source_repo_branch = var.github_branch

  regions = [{
    region       = "us-west2"
    num_replicas = 1
  }]

  lifecycle {
    prevent_destroy = true
  }
}

resource "railway_service_domain" "public" {
  service_id     = railway_service.ebwiki.id
  environment_id = railway_environment.production.id
  subdomain      = split(".", var.railway_service_domain_fqdn)[0]

  lifecycle {
    prevent_destroy = true
  }
}

resource "railway_custom_domain" "staging" {
  domain         = var.staging_hostname
  service_id     = railway_service.ebwiki.id
  environment_id = railway_environment.production.id

  lifecycle {
    prevent_destroy = true
  }
}

removed {
  from = doppler_service_token.railway_runtime

  lifecycle {
    destroy = false
  }
}

resource "railway_variable" "doppler_token" {
  name           = "DOPPLER_TOKEN"
  value          = var.staging_runtime_doppler_token
  service_id     = railway_service.ebwiki.id
  environment_id = railway_environment.production.id
}
