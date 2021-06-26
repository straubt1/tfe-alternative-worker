#!/bin/bash

# Static values
global_variables_file="/terraform/zzz_global.auto.tfvars"

# if this file exists, it likely means we are in the Apply Phase, so exit gracefully
if [[ -f "$global_variables_file" ]]; then
  exit 0
fi

# Retrieve information about the Workspace that could be useful
hostname=$(cat /terraform/zzz_backend_override.tf.json | jq -r '.terraform[0].backend[0].remote.hostname')
organization_name=$(cat /terraform/zzz_backend_override.tf.json | jq -r '.terraform[0].backend[0].remote.organization')
workspace_name=$(cat /terraform/zzz_backend_override.tf.json | jq -r '.terraform[0].backend[0].remote.workspaces.name')

# Add as many variables as you like
cat >> $global_variables_file << EOF
init_variable = "This was set via the Initialize Script, ${hostname} ${organization_name} ${workspace_name}"
EOF
