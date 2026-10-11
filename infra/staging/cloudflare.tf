resource "cloudflare_dns_record" "staging" {
  zone_id = var.cloudflare_zone_id
  name    = "staging"
  type    = "CNAME"
  content = railway_service_domain.public.domain
  proxied = true
  ttl     = 1
  comment = "Rails staging on Railway (OpenTofu infra/staging, GKT-462)"

  lifecycle {
    prevent_destroy = true
  }
}
