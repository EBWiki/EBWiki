variable "bootstrap_state_passphrase" {
  type        = string
  description = "Passphrase for bootstrap state encryption (16+ characters). Set TF_VAR_bootstrap_state_passphrase. Also stored in ebwiki/infra after apply."
  sensitive   = true
}

variable "cloudflare_token_maker" {
  type        = string
  description = "CLOUDFLARE_TOKEN_MAKER from grandkru/prd: API Tokens Edit only. Used as cloudflare.token_maker to create final DNS/R2 API tokens (not a chain of token-creating tokens)."
  sensitive   = true
}

variable "cloudflare_account_id" {
  type        = string
  description = "Cloudflare account ID (from zone read lookup)."
}

variable "cloudflare_zone_id" {
  type        = string
  description = "Cloudflare zone ID for ebwiki.org (legacy DNS and redirect)."
}

variable "cloudflare_grandkru_zone_id" {
  type        = string
  description = "Cloudflare zone ID for grandkru.com (staging hostname DNS)."
}

variable "railway_api_token" {
  type        = string
  description = "Railway token copied into ebwiki/infra as RAILWAY_TOKEN. Set from RAILWAY_API_TOKEN (grandkru/prd)."
  sensitive   = true
}

variable "doppler_project" {
  type        = string
  description = "Doppler project for infra secrets."
  default     = "ebwiki"
}

variable "doppler_stg_config" {
  type        = string
  description = "Doppler config the OpenTofu service account may access (staging secrets and runtime tokens)."
  default     = "stg"
}
