# Deployment policy import ID: repository:environment:policy_id
# https://github.com/integrations/terraform-provider-github/blob/v6.4.0/website/docs/r/repository_environment_deployment_policy.html.markdown#import

import {
  for_each = var.existing_release_smoke_environment ? toset(["release-smoke"]) : toset([])
  to       = github_repository_environment.release_smoke
  id       = "${var.github_repository}:${each.key}"
}

import {
  for_each = var.existing_main_policy_id == "" ? toset([]) : toset([var.existing_main_policy_id])
  to       = github_repository_environment_deployment_policy.release_smoke_main[0]
  id       = "${var.github_repository}:release-smoke:${each.key}"
}
