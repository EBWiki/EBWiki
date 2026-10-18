# Mint the Rollbar project access token for release automation (ebwiki/stg).
# Only ROLLBAR_ACCOUNT_API_KEY in grandkru/prd stays manual.

data "rollbar_project" "ebwiki" {
  name = var.rollbar_project_name
}

resource "rollbar_project_access_token" "release_smoke" {
  name       = "ebwiki-release-smoke"
  project_id = data.rollbar_project.ebwiki.id
  scopes     = ["post_server_item", "read"]
  token_type = "v2"
}

resource "doppler_secret" "rollbar_access_token_stg" {
  project = var.doppler_project
  config  = var.doppler_stg_config
  name    = "ROLLBAR_ACCESS_TOKEN"
  value   = rollbar_project_access_token.release_smoke.access_token

  depends_on = [doppler_environment.infra]
}
