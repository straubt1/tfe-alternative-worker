#!/bin/bash

# The /env/ folder does NOT persist, Environment Variable files must be set in both Plan and Apply Phases

# Retrieve information about the Workspace that could be useful
hostname=$(cat /terraform/zzz_backend_override.tf.json | jq -r '.terraform[0].backend[0].remote.hostname')
organization_name=$(cat /terraform/zzz_backend_override.tf.json | jq -r '.terraform[0].backend[0].remote.organization')
workspace_name=$(cat /terraform/zzz_backend_override.tf.json | jq -r '.terraform[0].backend[0].remote.workspaces.name')

# Add as many variables as you like
# Remember case sensitivity matters with Variable names
echo "This was set via the Initialize Script, ${hostname} ${organization_name} ${workspace_name}" > /env/TF_VAR_init_variable
