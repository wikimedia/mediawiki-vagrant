# Dockerfile for MediaWiki-Vagrant
# ---------------------------------
# https://www.mediawiki.org/wiki/MediaWiki-Vagrant
#
# Provisions a base Docker image for use with MediaWiki-Vagrant. This is not
# intended to be an example of the best way to use Docker. We are attempting
# to use the lxc container managed by Docker as a full virtual machine
# replacement rather than as a light weight service container. Once the image
# is built and running, MediaWiki-Vagrant will run puppet inside the container
# to provision a full stack MediaWiki development environment.
#

# Use base image that runs /sbin/init providing a "machine mode" container
FROM stackbrew/ubuntu-upstart:14.04
MAINTAINER MediaWiki-Vagrant <https://www.mediawiki.org/wiki/MediaWiki-Vagrant>

# Disable grub and lilo updates
ENV INITRD no

# Always report that this is a chroot
RUN dpkg-divert --local --rename --add /usr/bin/ischroot \
    && ln -sf /bin/true /usr/bin/ischroot

# Install required packages for using puppet to provision the container
RUN apt-get update \
    && INITRD=no DEBIAN_FRONTEND=noninteractive apt-get \
        -o Dpkg::Options::='--force-confdef' \
        -o Dpkg::Options::='--force-confold' \
        -o Dpkg::Options::='--force-unsafe-io' \
        install \
        --no-install-recommends --fix-broken --auto-remove --yes --quiet \
        apt-utils \
        curl \
        facter \
        lsb-release \
        openssh-server \
        puppet \
        puppet-common \
        ruby-hiera \
        sudo \
        virt-what \
        wget

# Setup things for the container in general
RUN ln -sf /usr/share/zoneinfo/Universal /etc/localtime

# Make state directory for sshd in case we need to start it directly for
# debugging.
RUN mkdir /var/run/sshd

# Create and configure vagrant user
RUN useradd --create-home -s /bin/bash vagrant \
    && adduser vagrant sudo \
    && echo -n 'vagrant:vagrant' | chpasswd \
    && sed -i.bkp -e \
        's/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/%sudo ALL=NOPASSWD:ALL/g' \
        /etc/sudoers \
    && mkdir -p /home/vagrant/.ssh \
    && echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key" > /home/vagrant/.ssh/authorized_keys \
    && chown -R vagrant: /home/vagrant/.ssh

# This makes somethings nicer in wmflabs
RUN groupadd --gid 500 wikidev \
    && adduser vagrant wikidev

# Cleanup junk
RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
