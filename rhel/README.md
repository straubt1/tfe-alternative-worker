# Rhel Alternative Image

> Note: Not officially supported for TFE.

## How to Use

**Build the Image**

```sh
docker build -t rhel-alt-worker --build-arg redhat_username="<insert>" --build-arg redhat_password="<insert>" .
```

**Debug the Image**

```sh
docker run --rm -it tfe-rhel-alt-worker /bin/bash
```
