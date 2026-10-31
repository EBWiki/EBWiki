# Approval gate for .github/workflows/release-tags.yml: tags are created only after
# a reviewer approves, and only from main.
resource "github_repository_environment" "release_tags" {
  environment       = local.release_tags_environment
  repository        = var.github_repository
  can_admins_bypass = false

  reviewers {
    users = [5750239]
  }

  deployment_branch_policy {
    protected_branches     = false
    custom_branch_policies = true
  }
}

resource "github_repository_environment_deployment_policy" "release_tags_main" {
  repository     = var.github_repository
  environment    = github_repository_environment.release_tags.environment
  branch_pattern = "main"
}
