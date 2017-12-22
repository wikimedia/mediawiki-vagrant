# Using libvirt (KVM/QEMU) with MediaWiki-Vagrant #

libvirt is a virtualization API.  It supports multiple backends
(hypervisors), including KVM/QEMU.



## Setup ##

Running MediaWiki-Vagrant in KVM/QEMU under libvirt requires to
install the libvirt Vagrant plugin. On a Fedora system, you can just
install the package vagrant-libvirt. For Debian see their wiki page
https://wiki.debian.org/KVM#Installation

At first download the Debian Jessie box:

  vagrant box add debian/contrib-jessie64
  # https://app.vagrantup.com/debian/boxes/contrib-jessie64

You would then need to convert the box to libvirt. Install the mutate plugin
either from your distribution package 'vagrant-mutate' or if not available:

  vagrant plugin install mutate

Then do the conversion:

  vagrant mutate debian/contrib-jessie64 libvirt

## Use ##

    vagrant up --provider=libvirt

## Caveats ##

  * Currently vagrant-libvirt does only support system VMs
    (cf. https://github.com/pradels/vagrant-libvirt/issues/272).
