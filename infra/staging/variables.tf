variable "state_passphrase" {
  type        = string
  description = "State and plan encryption passphrase, at least 16 characters. Set TF_VAR_state_passphrase. Never commit it."
  sensitive   = true
}

variable "cloudflare_dns_api_token" {
  type        = string
  description = "Cloudflare API token for ebwiki.org (legacy staging record and redirect rule). Set TF_VAR_cloudflare_dns_api_token from Doppler ebwiki/infra."
  sensitive   = true
  default     = null
}

variable "cloudflare_grandkru_dns_api_token" {
  type        = string
  description = "Cloudflare API token with DNS Write on grandkru.com only. Set TF_VAR_cloudflare_grandkru_dns_api_token from Doppler ebwiki/infra."
  sensitive   = true
  default     = null
}

variable "cloudflare_zone_id" {
  type        = string
  description = "Cloudflare zone ID for ebwiki.org (legacy staging.ebwiki.org)."
}

variable "cloudflare_grandkru_zone_id" {
  type        = string
  description = "Cloudflare zone ID for grandkru.com (ebwiki.staging.grandkru.com)."
}

variable "cloudflare_staging_dns_record_id" {
  type        = string
  description = "Cloudflare DNS record ID for the existing staging.ebwiki.org CNAME (adopt; content unchanged)."
}

variable "staging_hostname" {
  type        = string
  description = "Public staging hostname on Railway and in Doppler HOST (<site>.staging.grandkru.com)."
  default     = "ebwiki.staging.grandkru.com"
}

variable "doppler_project" {
  type        = string
  description = "Doppler project that holds staging secrets."
  default     = "ebwiki"
}

variable "doppler_config" {
  type        = string
  description = "Doppler config the Railway runtime loads via DOPPLER_TOKEN."
  default     = "stg"
}

variable "staging_runtime_doppler_token" {
  type        = string
  description = "Read-only Doppler service token for Railway (ebwiki/stg). Set TF_VAR_staging_runtime_doppler_token from ebwiki/infra after first-time setup."
  sensitive   = true
}

variable "staging_basic_auth_username" {
  type        = string
  description = "HTTP basic auth username for staging (STAGING_USERNAME). Set TF_VAR_staging_basic_auth_username in ebwiki/infra."
  sensitive   = true
}

variable "railway_project_id" {
  type        = string
  description = "Existing Railway project ID. Set TF_VAR_railway_project_id (GitHub variable or tfvars, not committed)."
}

variable "railway_service_id" {
  type        = string
  description = "Existing Railway service ID. Set TF_VAR_railway_service_id (GitHub variable or tfvars, not committed)."
}

variable "railway_environment_name" {
  type        = string
  description = "Railway environment name for the staging service."
  default     = "production"
}

variable "github_repo" {
  type        = string
  description = "GitHub repository connected to the Railway service."
  default     = "EBWiki/EBWiki"
}

variable "github_branch" {
  type        = string
  description = "Branch Railway builds for staging."
  default     = "main"
}

variable "railway_service_domain_fqdn" {
  type        = string
  description = "Existing Railway public hostname for import. Set TF_VAR_railway_service_domain_fqdn (not committed)."
}
