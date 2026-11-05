output "health_access_application_id" {
  description = "Cloudflare Access application ID for GET /health."
  value       = cloudflare_zero_trust_access_application.health.id
}

output "health_monitoring_service_token_id" {
  description = "Access service token ID for uptime checks (pair with client secret from state after apply)."
  value       = cloudflare_zero_trust_access_service_token.health_monitoring.id
}

output "health_monitoring_service_token_client_id" {
  description = "CF-Access-Client-Id header value for the monitoring service token."
  value       = cloudflare_zero_trust_access_service_token.health_monitoring.client_id
  sensitive   = true
}

output "health_protected_uris" {
  description = "Public URIs covered by Access (GET /up is not listed)."
  value       = [for destination in local.health_destinations : destination.uri]
}
