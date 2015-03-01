Using LXC with MediaWiki-Vagrant
================================

LXC (Linux Containers) is an operating-system-level virtualization environment
for running multiple isolated Linux systems (containers) on a single Linux
control host. -- https://en.wikipedia.org/wiki/LXC


Setup on a Ubuntu 14.04 host
----------------------------

Install LXC and helper programs for network and NFS:

    sudo apt-get install lxc lxc-templates cgroup-lite redir bridge-utils
    sudo apt-get install nfs-kernel-server

Add support for NFS to LXC apparmor profile
as described by http://bridge.grumpy-troll.org/2014/03/lxc-routed-on-ubuntu/

    echo "mount fstype=nfs," |
        sudo tee -a /etc/apparmor.d/abstractions/lxc/container-base
    echo "mount fstype=nfs4," |
        sudo tee -a /etc/apparmor.d/abstractions/lxc/container-base
    echo "mount fstype=rpc_pipefs," |
        sudo tee -a /etc/apparmor.d/abstractions/lxc/container-base
    sudo service apparmor restart

Install the latest version of Vagrant (1.7+ required).
There is no official PPA for Vagrant and the version shipped in Ubuntu 14.04
is too old to support the latest vagrant-lxc plugin. See
https://github.com/mitchellh/vagrant-installers/issues/12 for discussion of an
official PPA.
Check https://www.vagrantup.com/downloads.html for current version URL.

    wget https://dl.bintray.com/mitchellh/vagrant/vagrant_1.7.2_x86_64.deb
    sudo dpkg -i vagrant_1.7.2_x86_64.deb

Install the Vagrant LXC provider plugin:

    sudo apt-get install build-essential
    vagrant plugin install vagrant-lxc

Install custom sudo rules for vagrant-lxc (optional but recommended)
See https://github.com/fgrehm/vagrant-lxc/wiki/Avoiding-%27sudo%27-passwords

    vagrant lxc sudoers

Continue installing MediaWiki-Vagrant using normal instructions:

    git clone https://gerrit.wikimedia.org/r/mediawiki/vagrant
    cd vagrant
    git submodule update --init --recursive
    ./setup.sh

Vagrant may automatically select LXC as the default provider when it is
available, but if is not picked for you it can be forced:

    vagrant up --provider=lxc

You can also set `VAGRANT_DEFAULT_PROVIDER=lxc` in your shell environment to
tell Vagrant your preferred default provider.
