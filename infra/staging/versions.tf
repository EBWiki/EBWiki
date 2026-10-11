terraform {
  required_version = ">= 1.10.0"

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
  }

  backend "s3" {}

  encryption {
    key_provider "pbkdf2" "default" {
      passphrase = var.state_passphrase
    }

    method "aes_gcm" "default" {
      keys = key_provider.pbkdf2.default
    }

    state {
      method   = method.aes_gcm.default
      enforced = true
    }

    plan {
      method   = method.aes_gcm.default
      enforced = true
    }
  }
}
