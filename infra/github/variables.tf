variable "state_passphrase" {
  type        = string
  description = "State and plan encryption passphrase, at least 16 characters. Set TF_VAR_state_passphrase from Doppler ebwiki/infra."
  sensitive   = true
}

variable "github_owner" {
  type        = string
  description = "GitHub organization or user that owns the EBWiki repository."
  default     = "EBWiki"
}

variable "github_repository" {
  type        = string
  description = "Repository name (without owner)."
  default     = "EBWiki"
}

variable "github_token" {
  type        = string
  description = "GitHub PAT or fine-grained token for managing environments and Actions secrets. Set TF_VAR_github_token from GITHUB_TOKEN in ebwiki/infra. Never commit."
  sensitive   = true
}

variable "staging_username" {
  type        = string
  description = "STAGING_USERNAME for release smoke check (from Doppler ebwiki/stg). Set TF_VAR_staging_username via plan/apply scripts."
  sensitive   = true
}

variable "staging_password" {
  type        = string
  description = "STAGING_PASSWORD for release smoke check (from Doppler ebwiki/stg)."
  sensitive   = true
}

variable "rollbar_access_token" {
  type        = string
  description = "ROLLBAR_ACCESS_TOKEN for release smoke check (from Doppler ebwiki/stg)."
  sensitive   = true
}
