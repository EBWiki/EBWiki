locals {
  r2_bucket_name         = "ebwiki-tfstate-${random_id.bucket_suffix.hex}"
  r2_bucket_resource_key = "com.cloudflare.edge.r2.bucket.${var.cloudflare_r2_account_id}_default_${local.r2_bucket_name}"
  r2_s3_endpoint         = "https://${var.cloudflare_r2_account_id}.r2.cloudflarestorage.com"
}
