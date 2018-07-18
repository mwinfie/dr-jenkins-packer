FROM centos:7.5.1804
LABEL maintainer="Matthew Winfield <mwinfie@gmail.com>" \
    version="1.0" \
    description="This Dockerfile creates an image that \
installs Packer 1.2.4, Vagrant 2.1.2, and Virtualbox 5.2.14 \
to be used for creating Vagrant boxes that support the \
Virtualbox provider."

# Need root to build image
USER root

# install dev tools
RUN yum install -y \
      unzip \
      tar \
      gzip \
      wget && \
    yum clean all && rm -rf /var/cache/yum/*

ENV VAGRANT_HOME=/opt/vagrant

# install Hashicorp tools
RUN export PACKER_VERSION=1.2.4 && \
    export VAGRANT_VERSION=2.1.2 && \
    wget --directory-prefix=/tmp https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip && \
    unzip /tmp/packer_${PACKER_VERSION}_linux_amd64.zip -d /usr/local/bin && \
    wget --directory-prefix=/tmp https://releases.hashicorp.com/vagrant/${VAGRANT_VERSION}/vagrant_${VAGRANT_VERSION}_x86_64.rpm && \
    rpm -i /tmp/vagrant_${VAGRANT_VERSION}_x86_64.rpm && \
    ls -All /tmp && \
    mkdir -p $VAGRANT_HOME && \
    chown -R ${CONTAINER_USER}:${CONTAINER_GROUP} $VAGRANT_HOME && \
    rm -rf /tmp/*

# install Virtualbox (Example version: 5.2.12_122591_el7-1)
RUN export VIRTUALBOX_VERSION=5.2.14_123301_el7-1 && \
    mkdir -p /opt/virtualbox && \
    cd /etc/yum.repos.d/ && \
    wget http://download.virtualbox.org/virtualbox/rpm/el/virtualbox.repo && \
    yum install -y \
      dkms \
      kernel-devel && \
    yum -y groupinstall "Development Tools" && \
    if  [ "${VIRTUALBOX_VERSION}" = "latest" ]; \
      then yum install -y VirtualBox-5.2 ; \
      else yum install -y VirtualBox-5.2-${VIRTUALBOX_VERSION} ; \
    fi

# remove temporarily used tools and cleanup yum
RUN yum erase -y \
      unzip \
      wget && \
    yum clean all && rm -rf /var/cache/yum/*

# Switch back to user jenkins
USER $CONTAINER_UID
VOLUME $VAGRANT_HOME