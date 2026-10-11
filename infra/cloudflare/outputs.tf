output "health_access_application_id" {
  description = "Cloudflare Access application ID for /health."
  value       = cloudflare_zero_trust_access_application.health.id
}

output "health_monitor_service_token_id" {
  description = "Access service token ID (for policy references)."
  value       = cloudflare_zero_trust_access_service_token.health_monitor.id
}

output "health_monitor_client_id" {
  description = "CF-Access-Client-Id for monitors. Store in Doppler after apply."
  value       = cloudflare_zero_trust_access_service_token.health_monitor.client_id
}

output "health_monitor_client_secret" {
  description = "CF-Access-Client-Secret for monitors. Copy once from apply output into Doppler; never commit."
  value       = cloudflare_zero_trust_access_service_token.health_monitor.client_secret
  sensitive   = true
}

output "protected_health_urls" {
  description = "URLs that require Cloudflare Access after apply."
  value       = [for host in var.health_hosts : "https://${host}/health"]
}
