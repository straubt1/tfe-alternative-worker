# Vault Authentication

**Problem:** I wish to set Vault Authorization for a TFE workspace so that a Workspace does not need to provide any configuration.


## Proposed Solution

Leverage the Initialize Script as part of the Alternative Worker Image to inject [Environment Variables](https://www.terraform.io/docs/cli/config/environment-variables.html#tf_var_name) that will be picked up during the Terraform Execution Phase.


A simple example can be found in [init_custom_worker-autotfvars.sh](./init_custom_worker.sh) and some values are hardcoded into the script.

### High Level Flow

1. Retrieve information about Vault from AWS Secrets Manager, this includes an overly permissive token.
2. Using this token, generate a short lived token scoped to a policy that can be used during the Plan/Apply Phase.
3. Write the Environment Variables to the `/env/` directory so that they can be picked up in the Plan/Apply Phase.

### Vault Setup

Vault must have a policy with the same name as the Workspace, although a more robust approach with a wildcard may be something to look into here.

The policy would look something like this, with a name such as "teama-workspace":

```hcl
# Can read any secret in the teama directory
path "kv/teama/*" {
  capabilities = ["read","list"]
}

# Needed so that the Vault provider can interact with Vault
path "auth/token/create" {
  capabilities = ["create", "update"]
}
```

We also need some secrets on a path, something like "kv/teama/credentials".

Lastly, we need to make information about this Vault instance available via Secrets Manager, being sure that the TFE instance has the ability to read these values. 

> Note: You may also opt to use the [IAM Auth](https://www.vaultproject.io/docs/auth/aws) method with Vault

Example code in [./terraform](./terraform) demonstrates this configuration.


### Initialize Script

Static values on where to retrieve initial secrets from, these are non sensitive and baked into the script.
```sh
aws_sm_region="us-west-1"
aws_sm_prefix="tfe-vault"
```

---

Retrieve information about the Workspace Run, this can be used to interact with Vault
```sh
hostname=$(cat /terraform/zzz_backend_override.tf.json | jq -r '.terraform[0].backend[0].remote.hostname')
organization_name=$(cat /terraform/zzz_backend_override.tf.json | jq -r '.terraform[0].backend[0].remote.organization')
run_id=$(cat /env/TF_VAR_TFC_RUN_ID)
workspace_name=$(cat /env/TF_VAR_TFC_WORKSPACE_NAME)
```

---

Retrieve Vault connection/auth from cloud native secrets manager using the IAM Profile to authenticate
This token is overly permissive, and is only used to get a less permissive token based on the workspace name
```sh
export VAULT_ADDR=$(aws secretsmanager get-secret-value --region ${aws_sm_region} --secret-id ${aws_sm_prefix}-address | jq -r .SecretString)
export VAULT_TOKEN=$(aws secretsmanager get-secret-value --region ${aws_sm_region} --secret-id ${aws_sm_prefix}-token | jq -r .SecretString)
export VAULT_NAMESPACE=$(aws secretsmanager get-secret-value --region ${aws_sm_region} --secret-id ${aws_sm_prefix}-namespace | jq -r .SecretString)
```

---

Request a short lived token based on the workspace name
Write these values as files that will be picked up during the run

```sh
WORKSPACE_TOKEN=$(vault token create \
  -policy=${workspace_name} \
  -no-default-policy \
  -display-name="${workspace_name}-run" \
  -metadata="workspace=${workspace_name}" \
  -metadata="run-id=${run_id}" \
  -ttl=1h \
  -renewable=false \
  -field=token)

echo ${VAULT_ADDR} > /env/VAULT_ADDR
echo ${WORKSPACE_TOKEN} > /env/VAULT_TOKEN
echo ${VAULT_NAMESPACE} > /env/VAULT_NAMESPACE
```

