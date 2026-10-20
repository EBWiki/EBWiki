output "release_smoke_environment" {
  description = "GitHub Actions environment name for post-deploy smoke checks."
  value       = github_repository_environment.release_smoke.environment
}
