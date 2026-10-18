resource "random_password" "staging_password" {
  length  = 32
  special = false
}

resource "doppler_secret" "staging_username" {
  project = var.doppler_project
  config  = var.doppler_config
  name    = "STAGING_USERNAME"
  value   = var.staging_basic_auth_username
}

resource "doppler_secret" "staging_password" {
  project = var.doppler_project
  config  = var.doppler_config
  name    = "STAGING_PASSWORD"
  value   = random_password.staging_password.result
}

resource "doppler_secret" "staging_host" {
  project = var.doppler_project
  config  = var.doppler_config
  name    = "HOST"
  value   = var.staging_hostname
}
