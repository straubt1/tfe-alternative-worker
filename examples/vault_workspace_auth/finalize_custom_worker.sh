#!/bin/bash

# Retrieve Vault connection/auth from cloud native secrets manager using the IAM Profile to authenticate
# This token is overly permissive, and is only used to get a less permissive token based on the workspace name
export VAULT_ADDR=$(aws secretsmanager get-secret-value --region ${aws_sm_region} --secret-id ${aws_sm_prefix}-address | jq -r .SecretString)
export VAULT_TOKEN=$(aws secretsmanager get-secret-value --region ${aws_sm_region} --secret-id ${aws_sm_prefix}-token | jq -r .SecretString)
export VAULT_NAMESPACE=$(aws secretsmanager get-secret-value --region ${aws_sm_region} --secret-id ${aws_sm_prefix}-namespace | jq -r .SecretString)


# Revoke token as soon as Plan Phase is complete
# Vault will do this when the TTL expires, but this is a proactive revoke
vault token revoke $(cat /env/VAULT_TOKEN)