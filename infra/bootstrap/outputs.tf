output "doppler_infra_descriptor" {
  description = "Doppler environment for operator secrets (project.slug)."
  value       = "${var.doppler_project}.${doppler_environment.infra.slug}"
}

output "r2_state_key_staging" {
  description = "OpenTofu state object key for the staging stack."
  value       = "staging/terraform.tfstate"
}

output "r2_state_key_bootstrap" {
  description = "OpenTofu state object key for the bootstrap stack after migration."
  value       = "bootstrap/terraform.tfstate"
}

output "r2_state_key_cloudflare" {
  description = "OpenTofu state object key for the cloudflare stack (PR #4528)."
  value       = "cloudflare/terraform.tfstate"
}
