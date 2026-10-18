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
    condition     = github_repository_environment.release_smoke.environment == "release-smoke"
    error_message = "release-smoke environment must be planned"
  }
}

run "mutant_protected_branches_true" {
  command = plan

  variables {
    deployment_protected_branches = true
  }

  expect_failures = [
    check.release_smoke_deployment_branch_policy,
  ]
}

run "mutant_custom_branch_policies_false" {
  command = plan

  variables {
    deployment_custom_branch_policies = false
  }

  expect_failures = [
    check.release_smoke_deployment_branch_policy,
  ]
}

run "mutant_branch_pattern_wildcard" {
  command = plan

  variables {
    main_branch_pattern = "*"
  }

  expect_failures = [
    check.release_smoke_main_branch_pattern,
  ]
}

run "mutant_policy_block_removed" {
  command = plan

  variables {
    deployment_custom_branch_policies = false
    deployment_protected_branches     = true
  }

  expect_failures = [
    check.release_smoke_deployment_branch_policy,
  ]
}

run "mutant_deployment_policy_resource_removed" {
  command = plan

  variables {
    include_main_deployment_policy = false
  }

  expect_failures = [
    check.release_smoke_main_branch_pattern,
  ]
}

run "mutant_staging_username_secret_removed" {
  command = plan

  variables {
    staging_username_secret_name = "REMOVED_STAGING_USERNAME"
  }

  expect_failures = [
    check.release_smoke_secret_names,
  ]
}

run "mutant_secret_wrong_environment" {
  command = plan

  variables {
    staging_password_environment = "production"
  }

  expect_failures = [
    check.release_smoke_secret_environments,
  ]
}
