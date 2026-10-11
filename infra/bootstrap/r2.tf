resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "cloudflare_r2_bucket" "opentofu_state" {
  account_id = var.cloudflare_account_id
  name       = local.r2_bucket_name
  location   = "enam"

  lifecycle {
    prevent_destroy = true
  }
}

data "cloudflare_account_api_token_permission_groups_list" "r2_bucket_item_write" {
  account_id = var.cloudflare_account_id
  name       = "Workers%20R2%20Storage%20Bucket%20Item%20Write"
  scope      = "com.cloudflare.edge.r2.bucket"
}

resource "cloudflare_account_token" "r2_state" {
  account_id = var.cloudflare_account_id
  name       = "ebwiki-opentofu-r2-state"

  policies = [{
    effect = "allow"
    permission_groups = [{
      id = data.cloudflare_account_api_token_permission_groups_list.r2_bucket_item_write.result[0].id
    }]
    resources = jsonencode({
      (local.r2_bucket_resource_key) = "*"
    })
  }]
}
