mock_provider "github" {}

variables {
  state_passphrase     = "ci-test-passphrase-16chars"
  github_token         = "ghp_ci_validate_only_token"
  staging_username     = "ci-staging-user"
  staging_password     = "ci-staging-pass"
  rollbar_access_token = "ci-rollbar-token"
}

run "plan_release_smoke_environment" {
  command = plan

  assert {
    condition     = github_repository_environment.release_smoke.environment == "release-smoke"
    error_message = "release-smoke environment must exist"
  }
}
