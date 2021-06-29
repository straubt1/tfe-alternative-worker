terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "2.21.0"
    }
  }
}

provider "vault" {
  address = var.vault_address
  token   = var.vault_token
}

provider "aws" {
  region = "us-west-1"
}
