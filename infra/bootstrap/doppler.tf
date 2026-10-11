resource "doppler_environment" "infra" {
  project = var.doppler_project
  slug    = "infra"
  name    = "Infra (OpenTofu operator)"
}

resource "random_password" "state_passphrase" {
  length           = 32
  special          = true
  override_special = "-_.~"
}

resource "random_string" "staging_basic_auth_username" {
  length  = 16
  special = false
  upper   = false
}

resource "doppler_service_account" "opentofu_staging" {
  name           = "ebwiki-opentofu-staging"
  workplace_role = "no_access"
}

resource "doppler_project_member_service_account" "opentofu_staging" {
  project              = var.doppler_project
  service_account_slug = doppler_service_account.opentofu_staging.slug
  role                 = "collaborator"
  environments         = [var.doppler_stg_config]
}

resource "doppler_service_account_token" "opentofu_staging" {
  service_account_slug = doppler_service_account.opentofu_staging.slug
  name                 = "opentofu-staging-apply"
}

locals {
  doppler_infra_config = doppler_environment.infra.slug
}

resource "doppler_secret" "tf_var_bootstrap_state_passphrase" {
  project = var.doppler_project
  config  = local.doppler_infra_config
  name    = "TF_VAR_bootstrap_state_passphrase"
  value   = var.bootstrap_state_passphrase

  depends_on = [doppler_environment.infra]
}

resource "doppler_secret" "tf_var_state_passphrase" {
  project = var.doppler_project
  config  = local.doppler_infra_config
  name    = "TF_VAR_state_passphrase"
  value   = random_password.state_passphrase.result

  depends_on = [doppler_environment.infra]
}

resource "doppler_secret" "tf_var_cloudflare_dns_api_token" {
  project = var.doppler_project
  config  = local.doppler_infra_config
  name    = "TF_VAR_cloudflare_dns_api_token"
  value   = cloudflare_api_token.staging_ebwiki_dns.value

  depends_on = [doppler_environment.infra]
}

resource "doppler_secret" "cloudflare_dns_api_token" {
  project = var.doppler_project
  config  = local.doppler_infra_config
  name    = "CLOUDFLARE_DNS_API_TOKEN"
  value   = cloudflare_api_token.staging_ebwiki_dns.value

  depends_on = [doppler_environment.infra]
}

resource "doppler_secret" "tf_var_cloudflare_grandkru_dns_api_token" {
  project = var.doppler_project
  config  = local.doppler_infra_config
  name    = "TF_VAR_cloudflare_grandkru_dns_api_token"
  value   = cloudflare_api_token.staging_grandkru_dns.value

  depends_on = [doppler_environment.infra]
}

resource "doppler_secret" "cloudflare_grandkru_zone_id" {
  project = var.doppler_project
  config  = local.doppler_infra_config
  name    = "CLOUDFLARE_GRANDKRU_ZONE_ID"
  value   = var.cloudflare_grandkru_zone_id

  depends_on = [doppler_environment.infra]
}

resource "doppler_secret" "aws_access_key_id" {
  project = var.doppler_project
  config  = local.doppler_infra_config
  name    = "AWS_ACCESS_KEY_ID"
  value   = cloudflare_api_token.r2_state.id

  depends_on = [doppler_environment.infra, cloudflare_api_token.r2_state]
}

resource "doppler_secret" "aws_secret_access_key" {
  project = var.doppler_project
  config  = local.doppler_infra_config
  name    = "AWS_SECRET_ACCESS_KEY"
  value   = sha256(cloudflare_api_token.r2_state.value)

  depends_on = [doppler_environment.infra, cloudflare_api_token.r2_state]
}

resource "doppler_secret" "r2_bucket_name" {
  project = var.doppler_project
  config  = local.doppler_infra_config
  name    = "R2_BUCKET_NAME"
  value   = local.r2_bucket_name

  depends_on = [doppler_environment.infra, random_id.bucket_suffix]
}

resource "doppler_secret" "cloudflare_account_id" {
  project = var.doppler_project
  config  = local.doppler_infra_config
  name    = "CLOUDFLARE_ACCOUNT_ID"
  value   = var.cloudflare_account_id

  depends_on = [doppler_environment.infra]
}

resource "doppler_secret" "r2_s3_endpoint" {
  project = var.doppler_project
  config  = local.doppler_infra_config
  name    = "R2_S3_ENDPOINT"
  value   = local.r2_s3_endpoint

  depends_on = [doppler_environment.infra]
}

resource "doppler_secret" "doppler_apply_token" {
  project = var.doppler_project
  config  = local.doppler_infra_config
  name    = "DOPPLER_TOKEN"
  value   = doppler_service_account_token.opentofu_staging.api_key

  depends_on = [doppler_environment.infra]
}

resource "doppler_secret" "railway_token" {
  project = var.doppler_project
  config  = local.doppler_infra_config
  name    = "RAILWAY_TOKEN"
  value   = var.railway_api_token

  depends_on = [doppler_environment.infra]
}

resource "doppler_secret" "tf_var_staging_basic_auth_username" {
  project = var.doppler_project
  config  = local.doppler_infra_config
  name    = "TF_VAR_staging_basic_auth_username"
  value   = random_string.staging_basic_auth_username.result

  depends_on = [doppler_environment.infra]
}

resource "doppler_secret" "staging_expected_postgres_db" {
  project = var.doppler_project
  config  = local.doppler_infra_config
  name    = "STAGING_EXPECTED_POSTGRES_DB"
  value   = "ebwiki"

  depends_on = [doppler_environment.infra]
}
