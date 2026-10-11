resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "cloudflare_r2_bucket" "opentofu_state" {
  provider   = cloudflare.r2_admin
  account_id = var.cloudflare_account_id
  name       = local.r2_bucket_name
  location   = "enam"

  lifecycle {
    prevent_destroy = true
  }

  depends_on = [cloudflare_api_token.r2_admin]
}
