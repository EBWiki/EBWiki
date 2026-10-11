output "staging_hostname" {
  description = "Public staging hostname."
  value       = var.staging_hostname
}

output "railway_service_id" {
  description = "Railway service ID for ebwiki-web."
  value       = railway_service.ebwiki_web.id
}

output "railway_public_domain" {
  description = "Railway default public hostname (CNAME target for Cloudflare)."
  value       = railway_service_domain.public.domain
}

output "railway_custom_domain_id" {
  description = "Railway custom domain resource ID for staging.ebwiki.org."
  value       = railway_custom_domain.staging.id
}

output "cloudflare_staging_record_id" {
  description = "Cloudflare DNS record ID for staging.ebwiki.org."
  value       = cloudflare_dns_record.staging.id
}
