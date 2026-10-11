variable "cloudflare_account_id" {
  type        = string
  description = "Cloudflare account ID (Zero Trust / Access). Doppler: CLOUDFLARE_ACCOUNT_ID."
}

variable "cloudflare_zone_id" {
  type        = string
  description = "Zone ID for ebwiki.org. Doppler: CLOUDFLARE_ZONE_ID."
}

variable "health_hosts" {
  type        = list(string)
  description = "Hostnames whose /health path is protected. /up is not included."
  default     = ["ebwiki.org", "staging.ebwiki.org"]
}

variable "allowed_operator_email" {
  type        = string
  description = "Email allowed to sign in via Cloudflare Access to /health."
  default     = "mark@grandkru.com"
}

variable "monitoring_service_token_name" {
  type        = string
  description = "Display name for the Access service token used by uptime monitors."
  default     = "ebwiki-health-monitor"
}
