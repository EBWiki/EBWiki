resource "cloudflare_dns_record" "staging" {
  zone_id = var.cloudflare_zone_id
  name    = "staging"
  type    = "CNAME"
  content = railway_custom_domain.staging.dns_record_value
  proxied = true
  ttl     = 1
  comment = "EBWiki staging on Railway (GKT-462)"

  lifecycle {
    prevent_destroy = true
  }
}

resource "cloudflare_dns_record" "staging_railway_verify" {
  zone_id = var.cloudflare_zone_id
  name    = railway_custom_domain.staging.verification_host_label
  type    = "TXT"
  content = railway_custom_domain.staging.verification_record_value
  ttl     = 1
}
