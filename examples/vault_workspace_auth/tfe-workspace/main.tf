# terraform {
#   backend "remote" {
#     hostname     = ""
#     organization = ""
#     token        = ""

#     workspaces {
#       name = "teama-workspace"
#     }
#   }
# }

data "vault_generic_secret" "teama" {
  path = "kv/teama/credentials"
}

output "teama-credentials" {
  value     = data.vault_generic_secret.teama
  sensitive = true
}