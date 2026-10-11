variable "cloudflare_zone_id" {
  type        = string
  description = "Cloudflare zone ID for ebwiki.org."
}

variable "staging_hostname" {
  type        = string
  description = "Public hostname for Rails staging (custom domain on Railway and Cloudflare)."
  default     = "staging.ebwiki.org"
}

variable "doppler_project" {
  type        = string
  description = "Doppler project that holds staging secrets."
  default     = "ebwiki"
}

variable "doppler_config" {
  type        = string
  description = "Doppler config synced to the Railway staging service."
  default     = "stg"
}

variable "staging_basic_auth_username" {
  type        = string
  description = "HTTP basic auth username for staging (stored in Doppler as STAGING_USERNAME)."
  default     = "preview"
}

variable "railway_project_id" {
  type        = string
  description = "Existing Railway project ID (ebwiki-maps-preview)."
  default     = "5e9fc613-b97c-4ed2-a721-966aa54490c8"
}

variable "railway_service_id" {
  type        = string
  description = "Existing Railway service ID (ebwiki-web)."
  default     = "745e0c67-a192-44d1-ad5e-e4dc616720b7"
}

variable "railway_environment_name" {
  type        = string
  description = "Railway environment name (production in ebwiki-maps-preview)."
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

variable "railway_config_path" {
  type        = string
  description = "Railway config file in the repo (pre-deploy and health check)."
  default     = "railway.toml"
}

variable "railway_service_domain_fqdn" {
  type        = string
  description = "Existing Railway public hostname for import (verify in Railway before apply)."
  default     = "g6tfr1yl.up.railway.app"
}

variable "cloudflare_staging_dns_record_id" {
  type        = string
  description = "Optional Cloudflare DNS record ID for staging.ebwiki.org when adopting an existing record."
  default     = null
}
