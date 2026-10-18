check "release_smoke_deployment_branch_policy" {
  assert {
    condition = (
      length(github_repository_environment.release_smoke.deployment_branch_policy) == 1 &&
      github_repository_environment.release_smoke.deployment_branch_policy[0].protected_branches == false &&
      github_repository_environment.release_smoke.deployment_branch_policy[0].custom_branch_policies == true
    )
    error_message = "release-smoke must use custom branch policies with protected_branches false."
  }
}

check "release_smoke_main_branch_pattern" {
  assert {
    condition     = var.include_main_deployment_policy && github_repository_environment_deployment_policy.release_smoke_main[0].branch_pattern == "main"
    error_message = "release-smoke deployment policy must match branch main only."
  }
}

check "release_smoke_secret_names" {
  assert {
    condition = toset([
      github_actions_environment_secret.staging_username.secret_name,
      github_actions_environment_secret.staging_password.secret_name,
      github_actions_environment_secret.rollbar_access_token.secret_name,
    ]) == toset(["STAGING_USERNAME", "STAGING_PASSWORD", "ROLLBAR_ACCESS_TOKEN"])
    error_message = "release-smoke must define the three smoke check secret names."
  }
}

check "release_smoke_secret_environments" {
  assert {
    condition = alltrue([
      github_actions_environment_secret.staging_username.environment == "release-smoke",
      github_actions_environment_secret.staging_password.environment == "release-smoke",
      github_actions_environment_secret.rollbar_access_token.environment == "release-smoke",
    ])
    error_message = "smoke secrets must target the release-smoke environment."
  }
}
