variable "state_passphrase" {
  type        = string
  description = "State and plan encryption passphrase, at least 16 characters. Set TF_VAR_state_passphrase from Doppler ebwiki/infra."
  sensitive   = true

  validation {
    condition     = length(var.state_passphrase) >= 16
    error_message = "state_passphrase must be at least 16 characters."
  }
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

  validation {
    condition     = length(var.github_token) > 0
    error_message = "github_token must not be empty."
  }
}

variable "staging_username" {
  type        = string
  description = "STAGING_USERNAME for release smoke check (from Doppler ebwiki/stg). Set TF_VAR_staging_username via plan/apply scripts."
  sensitive   = true

  validation {
    condition     = length(var.staging_username) > 0
    error_message = "staging_username must not be empty."
  }
}

variable "staging_password" {
  type        = string
  description = "STAGING_PASSWORD for release smoke check (from Doppler ebwiki/stg)."
  sensitive   = true

  validation {
    condition     = length(var.staging_password) > 0
    error_message = "staging_password must not be empty."
  }
}

variable "rollbar_access_token" {
  type        = string
  description = "ROLLBAR_ACCESS_TOKEN for release smoke check (from Doppler ebwiki/stg)."
  sensitive   = true

  validation {
    condition     = length(var.rollbar_access_token) > 0
    error_message = "rollbar_access_token must not be empty."
  }
}

variable "existing_release_smoke_environment" {
  type        = bool
  description = "When true, adopt an existing release-smoke GitHub environment via import (set by github_preflight)."
  default     = false
}

variable "existing_main_policy_id" {
  type        = string
  description = "Deployment branch policy ID for main when adopting an existing environment (set by github_preflight)."
  default     = ""
}

variable "deployment_protected_branches" {
  type        = bool
  description = "github_repository_environment deployment_branch_policy protected_branches (test mutants override)."
  default     = false
}

variable "deployment_custom_branch_policies" {
  type        = bool
  description = "github_repository_environment deployment_branch_policy custom_branch_policies (test mutants override)."
  default     = true
}

variable "main_branch_pattern" {
  type        = string
  description = "Branch pattern for the release-smoke deployment policy (test mutants override)."
  default     = "main"
}

variable "include_main_deployment_policy" {
  type        = bool
  description = "When false, omits the main deployment policy resource (test mutants)."
  default     = true
}

variable "staging_username_secret_name" {
  type        = string
  description = "Secret name for staging username (test mutants override)."
  default     = "STAGING_USERNAME"
}

variable "staging_password_environment" {
  type        = string
  description = "Environment name for staging password secret (test mutants override)."
  default     = "release-smoke"
}
