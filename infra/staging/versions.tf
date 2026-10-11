terraform {
  required_version = ">= 1.6.0"

  required_providers {
    railway = {
      source  = "terraform-community-providers/railway"
      version = "~> 0.6.2"
    }
    doppler = {
      source  = "DopplerHQ/doppler"
      version = "~> 1.22.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  # Remote state: S3 object encryption plus OpenTofu state encryption (passphrase
  # from Doppler, never in git). See README.md for bucket bootstrap and who applies.
  backend "s3" {}

  encryption {
    key_provider "pbkdf2" "default" {
      passphrase = env("TOFU_STATE_PASSPHRASE")
    }

    method "aes_gcm" "default" {
      keys = key_provider.pbkdf2.default
    }

    state {
      method = method.aes_gcm.default
    }
  }
}
