output "staging_hostname" {
  description = "Public staging hostname."
  value       = var.staging_hostname
}

output "railway_custom_domain_dns_target" {
  description = "CNAME target Railway assigns for the staging custom domain."
  value       = railway_custom_domain.staging.dns_record_value
}

output "cloudflare_staging_grandkru_record_id" {
  description = "Cloudflare DNS record ID for ebwiki.staging.grandkru.com."
  value       = cloudflare_dns_record.staging_grandkru.id
}

output "cloudflare_legacy_staging_record_id" {
  description = "Cloudflare DNS record ID for legacy staging.ebwiki.org."
  value       = cloudflare_dns_record.legacy_staging_ebwiki.id
}
