# This Dockerfile builds the image used for the worker containers.
FROM ubuntu:bionic

# Pull in private CA in PEM format, add it to trusted certs, update by calling update-ca-certificates
RUN mkdir -p /usr/share/ca-certificates/extra && \
  echo "extra/ca-certificates.crt" >> /etc/ca-certificates.conf
ADD ca-certificates.crt /usr/share/ca-certificates/extra/ca-certificates.crt

# Install software used by TFE
RUN apt-get update && apt-get install -y --no-install-recommends \
  sudo unzip groff daemontools git-core ssh wget curl psmisc iproute2 openssh-client redis-tools netcat-openbsd ca-certificates nano jq

# Run update-ca-certificates to rebuild /etc/ssl/certs/ca-certificates.crt
RUN update-ca-certificates

ADD init_custom_worker.sh /usr/local/bin/init_custom_worker.sh
