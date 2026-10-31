variable "state_passphrase" {
  type        = string
  description = "State and plan encryption passphrase, at least 16 characters. Set TF_VAR_state_passphrase from Doppler STATE_PASSPHRASE. Never commit it."
  sensitive   = true
}

variable "cloudflare_account_id" {
  type        = string
  description = "Cloudflare account ID for ebwiki.org Zero Trust Access resources."
}

variable "cloudflare_zone_id" {
  type        = string
  description = "Cloudflare zone ID for ebwiki.org (ebwiki.org and staging.ebwiki.org)."
}

variable "health_protected_hostnames" {
  type        = list(string)
  description = "Public hostnames whose GET /health path is protected by Cloudflare Access. GET /up stays public."
  default     = ["ebwiki.org", "staging.ebwiki.org"]

  validation {
    condition     = length(var.health_protected_hostnames) > 0
    error_message = "health_protected_hostnames must include at least one hostname."
  }
}

variable "allowed_operator_email" {
  type        = string
  description = "Operator email allowed through Access for GET /health (Cloudflare identity). Set TF_VAR_allowed_operator_email from Doppler HEALTH_ACCESS_OPERATOR_EMAIL."
}

variable "access_application_name" {
  type        = string
  description = "Display name for the Access application in Cloudflare Zero Trust."
  default     = "EBWiki readiness (/health)"
}

variable "monitoring_service_token_name" {
  type        = string
  description = "Name for the Cloudflare Access service token used by uptime monitoring."
  default     = "ebwiki-health-monitoring"
}
