# Terraform Enterprise Alternative Worker

When Terraform Enterprise executes a Workspace Run, an ephemeral docker container is created for each phase "plan" and "apply. By default TFE ships with a vanilla container that works well for most uses, but there are some cases where it is necessary to customize this image.

This repository outlines how the Alternative Worker image is used during a Workspace Run and contains several examples.

## Workspace Run

![](images/workspace-run-flow.png)

There are two "Phases" to a run:

* Plan Phase
  * When `terraform plan` is executed
* Apply Phase
  * When `terraform apply` is executed
  * Will be skipped if a speculative plan was queued, there was a failure, a policy check failed, Workspace Run was cancelled or discarded.

Each Phase has three distinct steps; Initialize Script, Terraform Execution, and Finalize Script.

### Initialize Script

Details:

- Working Directory: `/`
- Run as user: `root`

<details><summary>Environment Variables</summary>
<p>

- HOSTNAME=00aabbccddee
- PWD=/
- HOME=/root
- SHLVL=1
- PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
</p>
</details>

This script gives you the ability to perform run time operations just *before* the Terraform Execution.

This file **must** be an executable shell script at `/usr/local/bin/init_custom_worker.sh`.

Known Limitations:
- Environment variables that are loaded in the Terraform Execution Phase are not available in this script.
- Unable to set Environment Variables in the Terraform Execution Phase.
- Unable to retrieve the Workspace Run Id.

During this Phase the `/terraform` directory is populated with the Terraform Code that will be executed as part of this Workspace Run.

Information about the Workspace associated with the Run can be found by parsing the TFE generated file in the `/terraform` directory.

```sh
hostname=$(cat /terraform/zzz_backend_override.tf.json | jq -r '.terraform[0].backend[0].remote.hostname')
organization_name=$(cat /terraform/zzz_backend_override.tf.json | jq -r '.terraform[0].backend[0].remote.organization')
workspace_name=$(cat /terraform/zzz_backend_override.tf.json | jq -r '.terraform[0].backend[0].remote.workspaces.name')
```

```json
{
  "terraform": [
    {
      "backend": [
        {
          "remote": {
            "hostname": "firefly.tfe.rocks",
            "organization": "someotherorg",
            "workspaces": {
              "name": "debug"
            }
          }
        }
      ]
    }
  ]
}
```

If you wish to stop the Run, exit with a non-zero status and the run will fail.

### Terraform Execution

Details:

- Working Directory: `/terraform`
- Run as user: `root`

<details><summary>Environment Variables</summary>
<p>

- ATLAS_RUN_ID=run-00aabbccddee
- TF_VAR_ATLAS_CONFIGURATION_SLUG=orgName/wsName
- TFC_WORKSPACE_NAME=wsName
- HOSTNAME=00aabbccddee
- TF_INPUT=0
- ATLAS_WORKSPACE_NAME=wsName
- HOME=/root
- OLDPWD=/
- TF_X_SHADOW=0
- TF_TEMP_LOG_PATH=/tmp/terraform-log00aabbccddee
- TF_REGISTRY_DISCOVERY_RETRY=2
- TF_VAR_ATLAS_CONFIGURATION_NAME=wsName
- TF_VAR_ATLAS_WORKSPACE_SLUG=orgName/wsName
- ATLAS_CONFIGURATION_SLUG=orgName/wsName
- TF_VAR_TFC_WORKSPACE_SLUG=orgName/wsName
- PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
- ATLAS_TOKEN=00aabbccddee.atlasv1.00aabbccddee
- TF_VAR_ATLAS_ADDRESS=https://tfe.company.com
- TF_APPEND_USER_AGENT=TFE/v202104-1
- TF_VAR_ATLAS_RUN_ID=run-00aabbccddee
- TF_PANICWRAP_STDERR=false:78
- TFC_WORKSPACE_SLUG=orgName/wsName
- TF_VAR_TFC_RUN_ID=run-00aabbccddee
- TF_VAR_ATLAS_WORKSPACE_NAME=wsName
- ATLAS_CONFIGURATION_NAME=wsName
- TF_VAR_TFE_RUN_ID=run-00aabbccddee
- ATLAS_WORKSPACE_SLUG=orgName/wsName
- CHECKPOINT_DISABLE=1
- TERRAFORM_CONFIG=/tmp/cli.tfrc
- TF_VAR_TFC_WORKSPACE_NAME=wsName
- PWD=/terraform
- TF_IN_AUTOMATION=1
- TFC_RUN_ID=run-00aabbccddee
- ATLAS_ADDRESS=https://tfe.company.com
- TFE_RUN_ID=run-00aabbccddee
- TF_FORCE_LOCAL_BACKEND=1
</p>
</details>

Contains the Terraform Code.

`/terraform/terraform.tfvars` file from the WS variables.
`zzz_ba` file with workspace backend information.

### Finalize Script

Details:

- Working Directory: `/`
- Run as user: `root`

<details><summary>Environment Variables</summary>
<p>

- HOSTNAME=00aabbccddee
- PWD=/
- HOME=/root
- SHLVL=1
- PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
</p>
</details>

This script gives you the ability to perform run time operations just *after* the Terraform Execution.

This file **must** be an executable shell script at `/usr/local/bin/finalize_custom_worker.sh`.


## Developing

For simplicity sake we will assume these commands are run directly on the TFE instance during development.

**Build the image**

Give the image a name for easy reference later, this name can be whatever you wish.

```sh
docker build -t tfe-alt-worker .
```

**Debug the Image**

Run the image and poke around to ensure things are running as you would expect.

```sh
docker run --rm -it tfe-alt-worker /bin/bash
```

## Tips

If you want to see what the default TFE worker looks like, you can run it from the TFE instance itself and poke around.

```sh
# Run an ephemeral container and bash into it
docker run --rm -it hashicorp/build-worker:now /bin/bash
```

---

The file `ca-certificates.crt` can be left empty if no private/additional Certificate Authorities are needed.

> Note: It is critical that we call update-ca-certificates in the Dockerfile to populate common trusted certificates.

---

If a Docker Registry is not easily available, it is possible to save this image as an archive.

Build that image and export as a tar, this can be saved like any other binary (i.e. S3, file share, etc...):
```sh
docker save tfe-alt-worker > tfe-alt-worker.tar
```

From the TFE instance, copy that tar and load it:
```sh
docker load --input tfe-alt-worker.tar
```

## Resources

[TFE Alternative Worker](https://www.terraform.io/docs/enterprise/install/installer.html#alternative-terraform-worker-image)
[Initialize Script](https://www.terraform.io/docs/enterprise/install/installer.html#initialize-script)
[Finalize Script](https://www.terraform.io/docs/enterprise/install/installer.html#finalize-script)
