locals {
  secrets = {
    "${var.secrets_manager_prefix}-vault-address"   = var.vault_address,
    "${var.secrets_manager_prefix}-vault-token"     = var.vault_token,
    "${var.secrets_manager_prefix}-vault-namespace" = var.vault_namespace,
  }
}

resource "aws_secretsmanager_secret" "vault" {
  for_each = local.secrets

  name                    = each.key
  description             = "Vault Secrets for TFE to authenticate to Vault."
  recovery_window_in_days = 0

  tags = {
    Name = each.key
  }
}

resource "aws_secretsmanager_secret_version" "vault" {
  for_each = local.secrets

  secret_id     = aws_secretsmanager_secret.vault[each.key].id
  secret_string = each.value
}

resource "aws_secretsmanager_secret_policy" "vault" {
  for_each = aws_secretsmanager_secret.vault

  secret_arn = each.value.arn

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "EnableAllPermissions",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "secretsmanager:GetSecretValue",
      "Resource": "*"
    }
  ]
}
POLICY
}
