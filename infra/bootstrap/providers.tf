# token_maker: CLOUDFLARE_TOKEN_MAKER (API Tokens Edit). Creates final DNS/R2 tokens only.
provider "cloudflare" {
  alias     = "token_maker"
  api_token = var.cloudflare_token_maker
}

# r2_admin: minted Workers R2 Storage Write token (short-lived), not the maker.
provider "cloudflare" {
  alias     = "r2_admin"
  api_token = cloudflare_api_token.r2_admin.value
}

provider "doppler" {
  # DOPPLER_TOKEN from DOPPLER_TOKEN_MAKER (grandkru/prd) during bootstrap.
}

provider "random" {}
