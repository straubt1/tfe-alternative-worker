#!/bin/bash

# The /env/ folder does NOT persist, Environment Variable files must be set in both Plan and Apply Phases

# Static values on where to retrieve initial secrets
aws_sm_region="us-west-1"
aws_sm_prefix="tfe-vault"

# Retrieve information about the Workspace Run, this can be used to interact with Vault
hostname=$(cat /terraform/zzz_backend_override.tf.json | jq -r '.terraform[0].backend[0].remote.hostname')
organization_name=$(cat /terraform/zzz_backend_override.tf.json | jq -r '.terraform[0].backend[0].remote.organization')
run_id=$(cat /env/TF_VAR_TFC_RUN_ID)
workspace_name=$(cat /env/TF_VAR_TFC_WORKSPACE_NAME)

# Retrieve Vault connection/auth from cloud native secrets manager using the IAM Profile to authenticate
# This token is overly permissive, and is only used to get a less permissive token based on the workspace name
export VAULT_ADDR=$(aws secretsmanager get-secret-value --region ${aws_sm_region} --secret-id ${aws_sm_prefix}-address | jq -r .SecretString)
export VAULT_TOKEN=$(aws secretsmanager get-secret-value --region ${aws_sm_region} --secret-id ${aws_sm_prefix}-token | jq -r .SecretString)
export VAULT_NAMESPACE=$(aws secretsmanager get-secret-value --region ${aws_sm_region} --secret-id ${aws_sm_prefix}-namespace | jq -r .SecretString)

# Request a short lived token based on the workspace name
WORKSPACE_TOKEN=$(vault token create \
  -policy=${workspace_name} \
  -no-default-policy \
  -display-name="${workspace_name}-run" \
  -metadata="workspace=${workspace_name}" \
  -metadata="run-id=${run_id}" \
  -ttl=1h \
  -renewable=false \
  -field=token)

# Write these values as files that will be picked up during the run
echo ${VAULT_ADDR} > /env/VAULT_ADDR
echo ${WORKSPACE_TOKEN} > /env/VAULT_TOKEN
echo ${VAULT_NAMESPACE} > /env/VAULT_NAMESPACE
