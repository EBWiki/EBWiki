output "staging_hostname" {
  description = "Public staging hostname."
  value       = var.staging_hostname
}

output "railway_custom_domain_dns_target" {
  description = "CNAME target Railway assigns for the staging custom domain."
  value       = railway_custom_domain.staging.dns_record_value
}

output "cloudflare_staging_record_id" {
  description = "Cloudflare DNS record ID for staging.ebwiki.org."
  value       = cloudflare_dns_record.staging.id
}
