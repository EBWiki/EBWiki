variable "bootstrap_state_passphrase" {
  type        = string
  description = "Passphrase for bootstrap state encryption (16+ characters). Set TF_VAR_bootstrap_state_passphrase. Also stored in ebwiki/infra after apply."
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

variable "doppler_stg_config" {
  type        = string
  description = "Doppler config the OpenTofu service account may access (staging secrets and runtime tokens)."
  default     = "stg"
}
