terraform {
  required_version = ">= 1.10.0"

  required_providers {
    github = {
      source  = "integrations/github"
      version = "6.4.0"
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
