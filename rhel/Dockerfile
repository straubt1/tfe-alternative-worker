FROM registry.access.redhat.com/rhel7
ARG redhat_username
ARG redhat_password

# Sign in to redhat so make available yum repo's
RUN subscription-manager register --username "$redhat_username" --password "$redhat_password" --auto-attach

# Copy in any needed additional CA Bundles
RUN mkdir -p /usr/share/
ADD ca-certificates.crt /etc/ssl/certs/ca-certificates.crt

# Install pre-requisites
RUN yum -y install unzip sudo git openssh wget curl psmisc iproute nmap-ncat openssl rpm-build redhat-rpm-config make gcc
RUN yum clean all

# Install Daemontools which isnt available in the redhat repo's
RUN cd /tmp && git clone https://github.com/jacobm3/daemontools-rpm.git
RUN cd /tmp/daemontools-rpm && wget http://cr.yp.to/daemontools/daemontools-0.76.tar.gz && ./buildrpm.sh
RUN rpm -ivh /root/rpmbuild/RPMS/x86_64/daemontools-0.76-1.el7.x86_64.rpm

# Install latest AWS CLI
RUN ["/bin/sh", "-c", "curl -k 'https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip' -o awscliv2.zip && unzip awscliv2.zip && ./aws/install"]

# Install version of Kubectl
RUN ["/bin/sh", "-c", "curl -LO 'https://storage.googleapis.com/kubernetes-release/release/v1.18.0/bin/linux/amd64/kubectl' && chmod +x ./kubectl && mv ./kubectl /usr/local/bin/kubectl"]
