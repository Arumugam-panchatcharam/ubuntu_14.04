FROM ubuntu:14.04

#RUN apt-get update && apt-get -y upgrade

# Install the following utilities (required by poky)

# Additional host packages

RUN sudo apt-get update && apt-get install -y \
        gcc  \
        g++ \
        diffstat \
        texinfo \
        chrpath \
        gcc-multilib \
        git \
        gawk \
        build-essential \
	libfuse-dev \
	libcurl4-openssl-dev \
	libxml2-dev \
	automake \
	libtool \
	wget \
	mime-support \
	pkg-config \
	autoconf \
        libtool \
        libncurses-dev \
        gettext \
        gperf \
        lib32z1 \
        libc6-i386 \
        g++-multilib \
        python-git \
        regina-rexx \
        python-setuptools \
        python2.7 \
        python-yaml \
        python-pip \
        device-tree-compiler \
        python-argparse \
        python-simplejson \
        openssh-client \
        coreutils \
        libreadline-dev \
        rpcbind nfs-common \
        vim \
        jq \
        squashfs-tools \
	bzip2 \
        dosfstools \
        mtools \
        parted \
        syslinux \
        tree \
        bzip2 \
        dosfstools \
        mtools \
        parted \
        syslinux \
        tree \
        regina-rexx \
        lib32z1 \
        lib32stdc++6 \
        autoconf \
        bc \
        flex \
        bison \
        libtool \
        curl \
        libfdt-dev 

# Add "repo" tool (used by many Yocto-based projects)

RUN curl http://storage.googleapis.com/git-repo-downloads/repo > /usr/local/bin/repo

RUN chmod a+x /usr/local/bin/repo


RUN DEBIAN_FRONTEND=noninteractive apt-get install -y openjdk-7-jdk


# do some fancy footwork to create a JAVA_HOME that's cross-architecture-safe

#RUN ln -svT "/usr/lib/jvm/java-7-openjdk-$(dpkg --print-architecture)" /docker-java-home
#
#ENV JAVA_HOME /docker-java-home
#
#
## Install Jfrog cli utility to deploy artifacts
#
#RUN cd /usr/bin; curl -fL https://getcli.jfrog.io | sh
#
#RUN chmod 755 /usr/bin/jfrog


# Create a non-root user that will perform the actual build

RUN id build 2>/dev/null || useradd --uid 1000 --create-home build

RUN echo "build ALL=(ALL) NOPASSWD: ALL" | tee -a /etc/sudoers


# Default sh to bash

RUN echo "dash dash/sh boolean false" | debconf-set-selections

RUN DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash


# Create toolchain directory required by ecm build for docsis gateway 

RUN mkdir -p /opt/toolchains/stbgcc-4.8-1.6

RUN chown -R build:build /opt


# Disable Host Key verification.

RUN mkdir -p /home/build/.ssh

RUN echo -e "Host *\n\tStrictHostKeyChecking no\n" > /home/build/.ssh/config

RUN chown -R build:build /home/build/.ssh

RUN mkdir -p /home/build/Package

COPY ./Package /home/build/Package/

RUN /home/build/Package/pkgtool_setup.sh

COPY ./stbgcc-4.8-1.6 /opt/toolchains/stbgcc-4.8-1.6/

USER build

ENV USER build

WORKDIR /home/build

CMD "/bin/bash"
