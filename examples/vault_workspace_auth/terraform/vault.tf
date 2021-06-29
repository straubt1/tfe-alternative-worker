# Enable Vault Things
resource "vault_mount" "kv" {
  path = "kv"
  type = "kv-v2"
}

resource "vault_auth_backend" "approle" {
  type = "approle"
}

# Policy
locals {
  workspaces = [
    "teama",
    "teamb"
  ]
}

resource "vault_policy" "workspaces" {
  for_each = toset(local.workspaces)
  name     = "${each.key}-workspace"

  policy = <<EOT
path "kv/${each.key}/*" {
  capabilities = ["read","list"]
}
path "auth/token/create" {
  capabilities = ["create", "update"]
}
EOT
}

# Secrets
resource "random_uuid" "secrets"{
  for_each = toset(local.workspaces)
}
resource "vault_generic_secret" "secrets" {
  for_each = toset(local.workspaces)

  path      = "kv/${each.key}/credentials"
  data_json = <<EOT
{
  "aws": "${random_uuid.secrets[each.key].id}"
}
EOT
}
