mock_provider "github" {}

variables {
  state_passphrase                   = "ci-test-passphrase-16chars"
  github_token                       = "ghp_ci_validate_only_token"
  staging_username                   = "ci-staging-user"
  staging_password                   = "ci-staging-pass"
  rollbar_access_token               = "ci-rollbar-token"
  existing_release_smoke_environment = false
  existing_main_policy_id            = ""
}

run "baseline_plan" {
  command = plan

  assert {
    condition = (
      length(github_repository_environment.release_smoke.deployment_branch_policy) == 1 &&
      github_repository_environment.release_smoke.deployment_branch_policy[0].protected_branches == false &&
      github_repository_environment.release_smoke.deployment_branch_policy[0].custom_branch_policies == true
    )
    error_message = "protected_branches must be false and custom_branch_policies must be true"
  }

  assert {
    condition     = github_repository_environment_deployment_policy.release_smoke_main.branch_pattern == "main"
    error_message = "branch_pattern must be main"
  }

  assert {
    condition = toset([
      github_actions_environment_secret.staging_username.secret_name,
      github_actions_environment_secret.staging_password.secret_name,
      github_actions_environment_secret.rollbar_access_token.secret_name,
    ]) == toset(["STAGING_USERNAME", "STAGING_PASSWORD", "ROLLBAR_ACCESS_TOKEN"])
    error_message = "smoke secret names must match STAGING_USERNAME STAGING_PASSWORD ROLLBAR_ACCESS_TOKEN"
  }

  assert {
    condition = alltrue([
      github_actions_environment_secret.staging_username.environment == "release-smoke",
      github_actions_environment_secret.staging_password.environment == "release-smoke",
      github_actions_environment_secret.rollbar_access_token.environment == "release-smoke",
    ])
    error_message = "smoke secrets must use the release-smoke environment"
  }

  assert {
    condition     = github_repository_environment.release_smoke.can_admins_bypass == false
    error_message = "release-smoke must set can_admins_bypass to false"
  }

  assert {
    condition     = contains(flatten([for r in github_repository_environment.release_smoke.reviewers : r.users]), 5750239)
    error_message = "release-smoke must include reviewer user id 5750239"
  }

  assert {
    condition     = github_repository_environment.release_tags.environment == "release-tags"
    error_message = "release-tags environment must be named release-tags"
  }

  assert {
    condition     = github_repository_environment.release_tags.can_admins_bypass == false
    error_message = "release-tags must set can_admins_bypass to false"
  }

  assert {
    condition     = contains(flatten([for r in github_repository_environment.release_tags.reviewers : r.users]), 5750239)
    error_message = "release-tags must include reviewer user id 5750239"
  }

  assert {
    condition = (
      github_repository_environment_deployment_policy.release_tags_main.branch_pattern == "main" &&
      github_repository_environment.release_tags.deployment_branch_policy[0].custom_branch_policies == true
    )
    error_message = "release-tags must deploy from main only"
  }
}
