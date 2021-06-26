# Installing Cloud CLI (or any other binaries)

In some cases Terraform may rely on tools such as cloud specific CLI's to operate a Terraform Run in Terraform Enterprise.

## CA Certificates

This file is empty and can remain empty if you are using only publicly trusted Certificate Authorities

## Dockerfile

Includes the 3 major public clouds as example, but any means needed to get those into the image are likely ok.
Just remember to ensure any cli is in the PATH.
