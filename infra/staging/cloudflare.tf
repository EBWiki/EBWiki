locals {
  staging_grandkru_record_name = trimsuffix(var.staging_hostname, ".grandkru.com")
}

resource "cloudflare_dns_record" "staging_grandkru" {
  provider = cloudflare.grandkru
  zone_id  = var.cloudflare_grandkru_zone_id
  name     = local.staging_grandkru_record_name
  type     = "CNAME"
  content  = railway_custom_domain.staging.dns_record_value
  proxied  = true
  ttl      = 1
  comment  = "EBWiki staging on Railway (GKT-462)"

  lifecycle {
    prevent_destroy = true
  }
}

resource "cloudflare_dns_record" "staging_railway_verify" {
  provider = cloudflare.grandkru
  zone_id  = var.cloudflare_grandkru_zone_id
  name     = railway_custom_domain.staging.verification_host_label
  type     = "TXT"
  content  = railway_custom_domain.staging.verification_record_value
  ttl      = 1
}

# Legacy staging.ebwiki.org CNAME (still points at suspended Render). Content is not changed by OpenTofu.
resource "cloudflare_dns_record" "legacy_staging_ebwiki" {
  provider = cloudflare.ebwiki
  zone_id  = var.cloudflare_zone_id
  name     = "staging"
  type     = "CNAME"
  content  = "legacy-render-suspended.onrender.com"
  proxied  = true
  ttl      = 1
  comment  = "Legacy staging hostname; redirect rule sends traffic to grandkru staging"

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [content]
  }
}

resource "cloudflare_ruleset" "legacy_staging_redirect" {
  provider    = cloudflare.ebwiki
  zone_id     = var.cloudflare_zone_id
  name        = "ebwiki-legacy-staging-redirect"
  description = "Redirect staging.ebwiki.org to ebwiki.staging.grandkru.com"
  kind        = "zone"
  phase       = "http_request_dynamic_redirect"

  rules = [{
    ref         = "redirect_legacy_staging_host"
    description = "Redirect legacy staging.ebwiki.org to grandkru staging"
    expression  = "(http.host eq \"staging.ebwiki.org\")"
    action      = "redirect"
    action_parameters = {
      from_value = {
        status_code = 301
        target_url = {
          expression = "concat(\"https://${var.staging_hostname}\", http.request.uri.path)"
        }
        preserve_query_string = true
      }
    }
  }]
}
