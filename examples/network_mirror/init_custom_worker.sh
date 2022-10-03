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

