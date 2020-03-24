# Terraform Enterprise Alternative Worker

In some cases Terraform may rely on tools such as cloud specific CLI's to operate a Terraform Run in Terraform Enterprise.

This repository has an example Dockerfile that maps in a private CA bundle, and adds any utilities needed.

> Note: It is critical that we call update-ca-certificates to populate common trusted certificates.

The file `ca-certificates.crt` can be left empty if no private/additional Certificate Authorities are needed.

## How to Use

**Build the Image**

```sh
docker build -t tfe-alt-worker .
```

**Debug the Image**

```sh
docker run --rm -it tfe-alt-worker /bin/bash
```

## Tips

If you want to see what the default TFE worker looks like, you can run it from the TFE instance itself and poke around.

```sh
# Run an ephemeral container and bash into it
docker run --rm -it hashicorp/build-worker:now /bin/bash
```

## Resources

[TFE Alternative Worker](https://www.terraform.io/docs/enterprise/install/installer.html#alternative-terraform-worker-image)
