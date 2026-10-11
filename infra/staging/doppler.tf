resource "doppler_secret" "staging_username" {
  project = var.doppler_project
  config  = var.doppler_config
  name    = "STAGING_USERNAME"
  value   = "adopted-in-doppler"

  lifecycle {
    ignore_changes = [value]
  }
}

resource "doppler_secret" "staging_password" {
  project = var.doppler_project
  config  = var.doppler_config
  name    = "STAGING_PASSWORD"
  value   = "adopted-in-doppler"

  lifecycle {
    ignore_changes = [value]
  }
}

resource "doppler_secret" "staging_host" {
  project = var.doppler_project
  config  = var.doppler_config
  name    = "HOST"
  value   = var.staging_hostname
}
