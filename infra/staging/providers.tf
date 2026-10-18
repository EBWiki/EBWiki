provider "railway" {
  # RAILWAY_TOKEN in the environment (Doppler ebwiki/infra only). Never in GitHub Actions.
}

provider "doppler" {
  # DOPPLER_TOKEN in the environment (Doppler ebwiki/infra for apply). Never commit token values.
}

provider "cloudflare" {
  alias     = "ebwiki"
  api_token = var.cloudflare_dns_api_token
}
