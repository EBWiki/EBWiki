output "doppler_infra_descriptor" {
  description = "Doppler config descriptor for operator commands (project.config)."
  value       = doppler_config.infra.descriptor
}

output "r2_state_key_staging" {
  description = "Suggested OpenTofu state object key for the staging stack."
  value       = "staging/terraform.tfstate"
}

output "r2_state_key_cloudflare" {
  description = "Suggested OpenTofu state object key for the cloudflare stack (PR #4528)."
  value       = "cloudflare/terraform.tfstate"
}
