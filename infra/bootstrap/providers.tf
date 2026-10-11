provider "cloudflare" {
  api_token = var.cloudflare_bootstrap_api_token
}

provider "doppler" {
  # DOPPLER_TOKEN in the environment (Mark's bootstrap token with write access).
}

provider "random" {}
