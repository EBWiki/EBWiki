provider "cloudflare" {
  alias     = "token_maker"
  api_token = var.cloudflare_token_maker
}

provider "cloudflare" {
  alias     = "r2_admin"
  api_token = cloudflare_api_token.r2_admin.value
}

provider "doppler" {
  # DOPPLER_TOKEN from DOPPLER_TOKEN_MAKER (grandkru/prd) during bootstrap.
}

provider "random" {}
