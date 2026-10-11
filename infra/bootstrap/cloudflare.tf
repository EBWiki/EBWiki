data "cloudflare_api_token_permission_groups_list" "dns_write" {
  provider = cloudflare.token_maker
  name     = "DNS%20Write"
  scope    = "com.cloudflare.api.account.zone"

  lifecycle {
    postcondition {
      condition     = length(self.result) == 1
      error_message = "Expected exactly one Cloudflare permission group named DNS Write for zone scope."
    }
  }
}

data "cloudflare_api_token_permission_groups_list" "r2_storage_write" {
  provider = cloudflare.token_maker
  name     = "Workers%20R2%20Storage%20Write"
  scope    = "com.cloudflare.api.account"

  lifecycle {
    postcondition {
      condition     = length(self.result) == 1
      error_message = "Expected exactly one Cloudflare permission group named Workers R2 Storage Write for account scope."
    }
  }
}

data "cloudflare_api_token_permission_groups_list" "r2_bucket_item_write" {
  provider = cloudflare.token_maker
  name     = "Workers%20R2%20Storage%20Bucket%20Item%20Write"
  scope    = "com.cloudflare.edge.r2.bucket"

  lifecycle {
    postcondition {
      condition     = length(self.result) == 1
      error_message = "Expected exactly one Cloudflare permission group named Workers R2 Storage Bucket Item Write for bucket scope."
    }
  }
}

data "cloudflare_api_token_permission_groups_list" "dynamic_url_redirects_write" {
  provider = cloudflare.token_maker
  name     = "Dynamic%20URL%20Redirects%20Write"
  scope    = "com.cloudflare.api.account.zone"

  lifecycle {
    postcondition {
      condition     = length(self.result) == 1
      error_message = "Expected exactly one Cloudflare permission group named Dynamic URL Redirects Write for zone scope."
    }
  }
}

data "cloudflare_api_token_permission_groups_list" "dynamic_url_redirects_read" {
  provider = cloudflare.token_maker
  name     = "Dynamic%20URL%20Redirects%20Read"
  scope    = "com.cloudflare.api.account.zone"

  lifecycle {
    postcondition {
      condition     = length(self.result) == 1
      error_message = "Expected exactly one Cloudflare permission group named Dynamic URL Redirects Read for zone scope."
    }
  }
}

resource "cloudflare_api_token" "staging_ebwiki_dns" {
  provider = cloudflare.token_maker
  name     = "ebwiki-org-staging-legacy-dns"

  policies = [{
    effect = "allow"
    permission_groups = [
      { id = data.cloudflare_api_token_permission_groups_list.dns_write.result[0].id },
      { id = data.cloudflare_api_token_permission_groups_list.dynamic_url_redirects_write.result[0].id },
      { id = data.cloudflare_api_token_permission_groups_list.dynamic_url_redirects_read.result[0].id },
    ]
    resources = jsonencode({
      "com.cloudflare.api.account.zone.${var.cloudflare_zone_id}" = "*"
    })
  }]
}

resource "cloudflare_api_token" "staging_grandkru_dns" {
  provider = cloudflare.token_maker
  name     = "grandkru-staging-dns-write"

  policies = [{
    effect = "allow"
    permission_groups = [{
      id = data.cloudflare_api_token_permission_groups_list.dns_write.result[0].id
    }]
    resources = jsonencode({
      "com.cloudflare.api.account.zone.${var.cloudflare_grandkru_zone_id}" = "*"
    })
  }]
}

resource "cloudflare_api_token" "r2_admin" {
  provider   = cloudflare.token_maker
  name       = "ebwiki-bootstrap-r2-admin"
  expires_on = timeadd(timestamp(), "24h")

  policies = [{
    effect = "allow"
    permission_groups = [{
      id = data.cloudflare_api_token_permission_groups_list.r2_storage_write.result[0].id
    }]
    resources = jsonencode({
      "com.cloudflare.api.account.${var.cloudflare_r2_account_id}" = "*"
    })
  }]

  lifecycle {
    ignore_changes = [expires_on]
  }
}

resource "cloudflare_api_token" "r2_state" {
  provider = cloudflare.token_maker
  name     = "ebwiki-opentofu-r2-state"

  policies = [{
    effect = "allow"
    permission_groups = [{
      id = data.cloudflare_api_token_permission_groups_list.r2_bucket_item_write.result[0].id
    }]
    resources = jsonencode({
      (local.r2_bucket_resource_key) = "*"
    })
  }]

  depends_on = [cloudflare_r2_bucket.opentofu_state]
}
