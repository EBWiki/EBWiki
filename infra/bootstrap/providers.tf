provider "cloudflare" {
  api_token = var.cloudflare_bootstrap_api_token
}

provider "doppler" {
  # DOPPLER_TOKEN in the environment (from DOPPLER_TOKEN_MAKER / grandkru/prd during bootstrap).
}

provider "random" {}
