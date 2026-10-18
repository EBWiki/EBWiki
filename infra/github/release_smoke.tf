resource "github_repository_environment" "release_smoke" {
  environment = local.release_smoke_environment
  repository  = var.github_repository

  deployment_branch_policy {
    protected_branches     = var.deployment_protected_branches
    custom_branch_policies = var.deployment_custom_branch_policies
  }
}

resource "github_repository_environment_deployment_policy" "release_smoke_main" {
  count          = var.include_main_deployment_policy ? 1 : 0
  repository     = var.github_repository
  environment    = github_repository_environment.release_smoke.environment
  branch_pattern = var.main_branch_pattern
}

resource "github_actions_environment_secret" "staging_username" {
  repository      = var.github_repository
  environment     = github_repository_environment.release_smoke.environment
  secret_name     = var.staging_username_secret_name
  plaintext_value = var.staging_username
}

resource "github_actions_environment_secret" "staging_password" {
  repository      = var.github_repository
  environment     = var.staging_password_environment
  secret_name     = "STAGING_PASSWORD"
  plaintext_value = var.staging_password
}

resource "github_actions_environment_secret" "rollbar_access_token" {
  repository      = var.github_repository
  environment     = github_repository_environment.release_smoke.environment
  secret_name     = "ROLLBAR_ACCESS_TOKEN"
  plaintext_value = var.rollbar_access_token
}
