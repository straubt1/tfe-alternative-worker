FROM ubuntu:bionic

# Pull in private CA in PEM format, add it to trusted certs, update ca, success
RUN mkdir -p /usr/share/ca-certificates/extra && \
  echo "extra/ca-certificates.crt" >> /etc/ca-certificates.conf
ADD ca-certificates.crt /usr/share/ca-certificates/extra/ca-certificates.crt

# Install software used by TFE
RUN apt-get update && apt-get install -y --no-install-recommends \
  sudo unzip groff daemontools git-core ssh wget curl psmisc iproute2 openssh-client redis-tools netcat-openbsd ca-certificates nano jq

# Run update-ca-certificates to rebuild /etc/ssl/certs/ca-certificates.crt≈
RUN update-ca-certificates

# Install latest AWS CLI
RUN ["/bin/sh", "-c", "curl -k 'https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip' -o awscliv2.zip && unzip awscliv2.zip && ./aws/install"]

# Install Vault
RUN curl -o vault.zip https://releases.hashicorp.com/vault/1.7.3/vault_1.7.3_linux_amd64.zip && \
  unzip vault.zip -d /usr/local/bin && \
  rm vault.zip

ADD init_custom_worker.sh /usr/local/bin/init_custom_worker.sh
ADD finalize_custom_worker.sh /usr/local/bin/finalize_custom_worker.sh