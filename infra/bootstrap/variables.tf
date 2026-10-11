variable "bootstrap_state_passphrase" {
  type        = string
  description = "Passphrase for this stack's local encrypted state (16+ characters). Set TF_VAR_bootstrap_state_passphrase. Not stored in Doppler."
  sensitive   = true
}

variable "cloudflare_bootstrap_api_token" {
  type        = string
  description = "One-time Cloudflare token with permission to create API tokens, account tokens, and R2 buckets. Set TF_VAR_cloudflare_bootstrap_api_token."
  sensitive   = true
}

variable "cloudflare_account_id" {
  type        = string
  description = "Cloudflare account ID."
}

variable "cloudflare_zone_id" {
  type        = string
  description = "Cloudflare zone ID for ebwiki.org (DNS token scope)."
}

variable "doppler_project" {
  type        = string
  description = "Doppler project for infra secrets."
  default     = "ebwiki"
}

variable "doppler_infra_config" {
  type        = string
  description = "Doppler config name that holds OpenTofu operator secrets."
  default     = "infra"
}

variable "doppler_infra_environment" {
  type        = string
  description = "Doppler environment slug for the infra config."
  default     = "prd"
}

variable "doppler_stg_config" {
  type        = string
  description = "Doppler config the staging stack and runtime use."
  default     = "stg"
}
