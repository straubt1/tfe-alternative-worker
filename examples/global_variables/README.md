# Global Variables

**Problem:** I wish to set Terraform Variables for all Workspaces automatically.

## Initial Thought

One potential solution here is to have an out of band process that writes Terraform Variables to every Workspace, this is also supported by the Workspace Creator/Consumer model, however there are some challenges based on some organizations current status.

- Workspace Consumers that need the ability to manage Workspace Variables would be able to interact with the variables, even delete or modify them.
- New Workspaces that are created might not have values set.
- Development of that out of band process might be too big a lift for the current organization.
- There could be thousands of workspaces and keeping them all up to date could prove challenging.

## Proposed Solution

Leverage the Initialize Script as part of the Alternative Worker Image to inject a Terraform Variables (*.tfvars) file before Terraform executes a plan.

> Note: setting TF_VAR_* type environment variables would be great here, however that is not currently possible with an Initialize Script.

In this simple example the values are hardcoded into the script, however these could easily be pulled from external sources.

```sh
cat >> /terraform/zzz_global.auto.tfvars << EOF
init_variable = "This was set via the Initialize Script, ${hostname} ${organization_name} ${workspace_name}"
EOF
```

Many variable assignments could be made here.

### TF Vars

There are several ways we could inject these values based on the desired result.

> Important Variable presence note with regard to a TFE Workspace, `terraform.tfvars` file wins ALL fights, if a Terraform Variable is assigned here, this is the value it will use.

**Option 1 - .auto.tfvars**

Write these values to a file such as `zzz_global.auto.tfvars` so that they are [auto loaded](https://www.terraform.io/docs/language/values/variables.html#variable-definitions-tfvars-files) based on the `.auto.tfvars` file extension. This could also be built with `.auto.tfvars.json` file if a more programmatic approach was desired.

This approach (which is what the example in this directory uses) maintains a clear distinction of the files we are manipulating during the Initialize Script.

**Option 2 - terraform.tfvars**

The file `/terraform/terraform.tfvars` is generated as part of the Workspace Run and contains any Terraform Variable assigned in the [Workspace](https://www.terraform.io/docs/cloud/workspaces/variables.html#managing-variables-in-the-ui).

We could append to this file instead of creating the `zzz_global.auto.tfvars`, which would have the following affects:

- If a value was assigned via a Workspace Variable
  - Terraform would error with 'The argument "init_variable" was already set..."'
- If a value was assigned via an `.auto.tfvars` file, this value would override with no message to the end user

## Challenges

This approach of modifying/adding Terraform files just before Terraform executes does have some issues.

### Variable Declaration

If a Workspace does not declare a variable that you auto assign, i.e. the Workspace does not have something like this:

```hcl
variable "init_variable" {}
```

The Terraform will run, however a warning will be displayed:

```sh
│ Warning: Value for undeclared variable
│ 
│ The root module does not declare a variable named "init_variable" but a
│ value was found in file "zzz_global.auto.tfvars". If you meant to use this
│ value, add a "variable" block to the configuration.
```

One solution to this could be to do a parse of the `/terraform` directory for a variable declaration block in a *.tf files and dynamically include/exclude that assignment.

### Variable Secrets

If a variable assignment is injected that is a secret, the Workspace Consumer could add code to display that value, something like this:

```hcl
output "init_variable" {
  value = var.init_variable
}
```

## Dockerfile

`jq` is added for easy JSON manipulation in this example but that parsing could be done several ways.

## Reference

[Override Files](https://www.terraform.io/docs/language/files/override.html)
