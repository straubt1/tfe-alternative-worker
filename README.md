# Terraform Enterprise Alternative Worker

When Terraform Enterprise executes a Workspace Run, an ephemeral docker container is created for each phase "plan" and "apply. By default TFE ships with a vanilla container that works well for most uses, but there are some cases where it is necessary to customize this image.

This repository outlines how the Alternative Worker image is used during a Workspace Run and contains several examples.



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

## Resources

[TFE Alternative Worker](https://www.terraform.io/docs/enterprise/install/installer.html#alternative-terraform-worker-image)
[Initialize Script]()
[Finalize Script]()
