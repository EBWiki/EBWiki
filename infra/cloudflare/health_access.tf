resource "cloudflare_zero_trust_access_service_token" "health_monitor" {
  account_id = var.cloudflare_account_id
  name       = var.monitoring_service_token_name
  duration   = "8760h"

  lifecycle {
    create_before_destroy = true
  }
}

resource "cloudflare_zero_trust_access_policy" "health_operator" {
  account_id = var.cloudflare_account_id
  name       = "EBWiki /health operator"
  decision   = "allow"

  include = [{
    email = {
      email = var.allowed_operator_email
    }
  }]
}

resource "cloudflare_zero_trust_access_policy" "health_monitoring" {
  account_id = var.cloudflare_account_id
  name       = "EBWiki /health monitoring service token"
  decision   = "non_identity"

  include = [{
    service_token = {
      token_id = cloudflare_zero_trust_access_service_token.health_monitor.id
    }
  }]
}

resource "cloudflare_zero_trust_access_application" "health" {
  zone_id = var.cloudflare_zone_id
  name    = "EBWiki /health (private readiness page)"
  domain  = local.primary_domain
  type    = "self_hosted"

  self_hosted_domains  = local.health_paths
  app_launcher_visible = false

  policies = [
    {
      id         = cloudflare_zero_trust_access_policy.health_operator.id
      precedence = 1
    },
    {
      id         = cloudflare_zero_trust_access_policy.health_monitoring.id
      precedence = 2
    },
  ]
}
