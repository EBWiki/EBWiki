resource "cloudflare_zero_trust_access_service_token" "health_monitoring" {
  account_id = var.cloudflare_account_id
  name       = var.monitoring_service_token_name
  duration   = "8760h"
}

resource "cloudflare_zero_trust_access_policy" "health_allow" {
  account_id = var.cloudflare_account_id
  name       = "EBWiki /health operators and monitoring"
  decision   = "allow"

  include = [
    {
      email = {
        email = var.allowed_operator_email
      }
    },
    {
      service_token = {
        token_id = cloudflare_zero_trust_access_service_token.health_monitoring.id
      }
    },
  ]
}

resource "cloudflare_zero_trust_access_application" "health" {
  zone_id                   = var.cloudflare_zone_id
  type                      = "self_hosted"
  name                      = var.access_application_name
  domain                    = local.primary_health_domain
  app_launcher_visible      = false
  destinations              = local.health_destinations
  service_auth_401_redirect = true

  policies = [{
    id         = cloudflare_zero_trust_access_policy.health_allow.id
    precedence = 1
  }]
}
