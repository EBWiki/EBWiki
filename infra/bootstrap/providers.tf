provider "cloudflare" {
  api_token = var.cloudflare_bootstrap_api_token
}

provider "doppler" {
  # DOPPLER_TOKEN in the environment (PR Manager bootstrap token with write access).
}

provider "random" {}
