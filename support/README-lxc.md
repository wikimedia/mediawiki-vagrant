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

    wget https://releases.hashicorp.com/vagrant/1.8.1/vagrant_1.8.1_x86_64.deb
    sudo dpkg -i vagrant_1.8.1_x86_64.deb

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

Setup on a Debian Jessie host
-----------------------------

Install LXC and helper programs for network and NFS:

    sudo apt-get install lxc libvirt-bin dnsmasq-base
    sudo apt-get install nfs-kernel-server

Install the latest version of Vagrant (1.7+ required).  Jessie shipped with
1.6.5, which is too old.  For the ambituous, pinning 1.7.2 from Debian
testing might be an option, otherwise you should install the package provided
at vagrantup.com. Check https://www.vagrantup.com/downloads.html for the
most up to date download URL.

    wget https://releases.hashicorp.com/vagrant/1.8.1/vagrant_1.8.1_x86_64.deb
    sudo dpkg -i vagrant_1.8.1_x86_64.deb

Install the Vagrant LXC provider plugin:

    sudo apt-get install build-essential
    vagrant plugin install vagrant-lxc

Install custom sudo rules for vagrant-lxc (optional but recommended)
See https://github.com/fgrehm/vagrant-lxc/wiki/Avoiding-%27sudo%27-passwords

    vagrant lxc sudoers

Edit /etc/lxc/default.conf so that it includes the following:

    lxc.network.type = veth
    lxc.network.link = virbr0
    lxc.network.flags = up
    lxc.network.hwaddr = 00:16:3e:xx:xx:xx

Set the default network, start it, and configure it to start automatically.

    sudo virsh -c lxc:/// net-define /etc/libvirt/qemu/networks/default.xml
    sudo virsh -c lxc:/// net-start default
    sudo virsh -c lxc:/// net-autostart default

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


Setup on a Fedora 22 host
----------------------------

Since Fedora 22, everything is packaged, you just need to remember all the
packages:

    sudo dnf install lxc lxc-templates lxc-extra vagrant vagrant-libvirt \
    vagrant-lxc vagrant-libvirt-doc gcc ruby-devel rubygems libvirt-devel \
    redir nfs-utils

Now you can simplify your life reducing the sudo passwords to type in vagrant:

    sudo cp /usr/share/vagrant/gems/doc/vagrant-libvirt-0.0.*/polkit/10-vagrant-libvirt.rules /usr/share/polkit-1/rules.d/

Start NFS and allow access to it:

    sudo systemctl start rpcbind.service nfs-idmap.service nfs-server.service
    sudo firewall-cmd --zone=internal --change-interface=virbr0
    sudo firewall-cmd --permanent --zone=public --add-service=nfs
    sudo firewall-cmd --permanent --zone=public --add-service=rpc-bind
    sudo firewall-cmd --permanent --zone=public --add-service=mountd
    sudo firewall-cmd --permanent --zone=public --add-port=2049/udp
    sudo firewall-cmd --reload

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
