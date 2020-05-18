# Rhel Alternative Image

> Note: Not officially supported for TFE.

> Note: Pull the base image `registry.access.redhat.com/rhel7` first: <https://access.redhat.com/containers/?tab=images&get-method=red-hat-login#/registry.access.redhat.com/rhel7>

## How to Use

**Build the Image**

```sh
docker build -t rhel-alt-worker --build-arg redhat_username="<insert>" --build-arg redhat_password="<insert>" .
```

**Debug the Image**

```sh
docker run --rm -it tfe-rhel-alt-worker /bin/bash
```
