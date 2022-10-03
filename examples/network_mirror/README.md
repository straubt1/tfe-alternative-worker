# Network Mirror

**Problem:** I wish to pull Terraform Providers from a private location utilizing Terraform Network Mirror.

## Initial Thought

By default the Terraform Worker will reach out over the internet to the Terraform Registry to pull down the Terraform Providers. In an environment where internet egress (with  or without a proxy) isn't possible, or providers much be sourced from a trusted location, an alternative is needed. Discussions around all the different ways to source providers is out of scope for this, as we will focus on using the [Network Mirror Protocol](https://www.terraform.io/internals/provider-network-mirror-protocol) to source Terraform Providers.

## Proposed Solution

Leverage the Initialize Script as part of the Alternative Worker Image to inject a network mirror configuration and credentials, as needed, that will be picked up during the Terraform Execution Phase.

## Custom Worker Configuration

To configure a network mirror, the `init_custom_worker.sh` script must be included in the docker file. This script will be used to modify the automatically generated `/tmp/cli.tfrc` file. We will be adding a credentials section if the network mirror location needs a bearer token for authentication and the provider installation configuration. In this example below we are using an artifactory repository which is configured to require a token. This could also be a S3 bucket or some other web server that is hosting the Terraform Providers.

Note: This is only for Terraform Providers, the source for the Terraform OSS Binaries are not configured with Network Mirror.

Inside the `init_custom_worker.sh` script

```bash
#!/bin/bash

cat >> /tmp/cli.tfrc <<EOF

credentials "your-jfrog-url" {
  token = "jfrog-token"
}

provider_installation {
    direct {
        exclude = ["registry.terraform.io/*/*"]
    }
    network_mirror {
        url = "https://your-jfrog-url/artifactory/api/terraform/providers/repo-name/"
    }
}
EOF
```

In the above example we have two sections we are adding, the `credentials` and the `provider_installation`

The `credentials` is only used for network mirrors that support bearer token authentication, otherwise anonymous access is required and this section can be left out. For sake of simplicity, in this example the token is hard coded into the customer worker container. Alternatively it would be possible for the `init_custom_worker.sh` script to call out to an external service for a token, or use the `global_variables` example, to pass in a token at run time, with setting a environment variable at the workspace level.

The `provider_installation` section is broken into two parts, the exclusion, and the network mirror. In this example, we are forcibly excluding the public registry and adding a single `network_mirror` We could source additional network mirrors if there are multiple `network_mirrors` to pull providers from.

## Reference

[Provider Network Mirror Protocol](https://www.terraform.io/internals/provider-network-mirror-protocol)
[Alternative Terraform worker image](https://www.terraform.io/enterprise/install/interactive/installer#alternative-terraform-worker-image)
[Terraform Registry](https://www.jfrog.com/confluence/display/JFROG/Terraform+Registry)