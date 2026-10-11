resource "doppler_config" "infra" {
  project     = var.doppler_project
  environment = var.doppler_infra_environment
  name        = var.doppler_infra_config
}

resource "random_password" "state_passphrase" {
  length           = 32
  special          = true
  override_special = "-_.~"
}

resource "doppler_service_token" "stg_apply" {
  project = var.doppler_project
  config  = var.doppler_stg_config
  name    = "opentofu-stg-apply"
  access  = "read/write"
}

resource "doppler_secret" "tf_var_state_passphrase" {
  project = var.doppler_project
  config  = doppler_config.infra.name
  name    = "TF_VAR_state_passphrase"
  value   = random_password.state_passphrase.result

  depends_on = [doppler_config.infra]
}

resource "doppler_secret" "tf_var_cloudflare_dns_api_token" {
  project = var.doppler_project
  config  = doppler_config.infra.name
  name    = "TF_VAR_cloudflare_dns_api_token"
  value   = cloudflare_api_token.staging_dns.value

  depends_on = [doppler_config.infra]
}

resource "doppler_secret" "cloudflare_dns_api_token" {
  project = var.doppler_project
  config  = doppler_config.infra.name
  name    = "CLOUDFLARE_DNS_API_TOKEN"
  value   = cloudflare_api_token.staging_dns.value

  depends_on = [doppler_config.infra]
}

resource "doppler_secret" "aws_access_key_id" {
  project = var.doppler_project
  config  = doppler_config.infra.name
  name    = "AWS_ACCESS_KEY_ID"
  value   = cloudflare_account_token.r2_state.id

  depends_on = [doppler_config.infra]
}

resource "doppler_secret" "aws_secret_access_key" {
  project = var.doppler_project
  config  = doppler_config.infra.name
  name    = "AWS_SECRET_ACCESS_KEY"
  value   = sha256(cloudflare_account_token.r2_state.value)

  depends_on = [doppler_config.infra]
}

resource "doppler_secret" "r2_bucket_name" {
  project = var.doppler_project
  config  = doppler_config.infra.name
  name    = "R2_BUCKET_NAME"
  value   = local.r2_bucket_name

  depends_on = [doppler_config.infra]
}

resource "doppler_secret" "cloudflare_account_id" {
  project = var.doppler_project
  config  = doppler_config.infra.name
  name    = "CLOUDFLARE_ACCOUNT_ID"
  value   = var.cloudflare_account_id

  depends_on = [doppler_config.infra]
}

resource "doppler_secret" "r2_s3_endpoint" {
  project = var.doppler_project
  config  = doppler_config.infra.name
  name    = "R2_S3_ENDPOINT"
  value   = local.r2_s3_endpoint

  depends_on = [doppler_config.infra]
}

resource "doppler_secret" "doppler_stg_apply_token" {
  project = var.doppler_project
  config  = doppler_config.infra.name
  name    = "DOPPLER_TOKEN"
  value   = doppler_service_token.stg_apply.key

  depends_on = [doppler_config.infra]
}
