# This Dockerfile builds the image used for the worker containers.
FROM ubuntu:xenial

# Pull in private CA in PEM format, add it to trusted certs, update ca, success 
RUN mkdir -p /usr/share/ca-certificates/extra && \
  echo "extra/ca-certificates.crt" >> /etc/ca-certificates.conf
ADD ca-certificates.crt /usr/share/ca-certificates/extra/ca-certificates.crt

# Install software used by TFE
RUN apt-get update && apt-get install -y --no-install-recommends \
  sudo unzip groff daemontools git-core ssh wget curl psmisc iproute2 openssh-client redis-tools netcat-openbsd ca-certificates

# Run update-ca-certificates to rebuild /etc/ssl/certs/ca-certificates.crt
RUN update-ca-certificates

# Install latest AWS CLI
RUN ["/bin/sh", "-c", "curl -k 'https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip' -o awscliv2.zip && unzip awscliv2.zip && ./aws/install"]

# Install latest Azure CLI
RUN curl -skL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Install latest Google Cloud CLI
RUN apt-get install -y --no-install-recommends python3
RUN curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-286.0.0-linux-x86_64.tar.gz && \
  tar zxvf google-cloud-sdk-286.0.0-linux-x86_64.tar.gz google-cloud-sdk && \
  ./google-cloud-sdk/install.sh
RUN echo ". /google-cloud-sdk/path.bash.inc" >> /root/.bashrc
