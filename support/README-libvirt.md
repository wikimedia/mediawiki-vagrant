# Using libvirt (KVM/QEMU) with MediaWiki-Vagrant #

libvirt is a virtualization API.  It supports multiple backends
(hypervisors), including KVM/QEMU.



## Setup ##

Running MediaWiki-Vagrant in KVM/QEMU under libvirt requires to
install the libvirt Vagrant plugin.  In a Fedora system, you can just
install the package vagrant-libvirt.

In addition you need convert the Ubuntu Trusty VirtualBox box that
MediaWiki-Vagrant uses by default for the libvirt provider.  To do
that:

1. Install the mutate Vagrant plugin by "vagrant plugin install mutate".
2. Download the Ubuntu Trusty VirtualBox box by "vagrant box add
   trusty-cloud
   https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box".
3. Convert the box by "vagrant mutate trusty-cloud libvirt".



## Use ##

    vagrant up --provider=libvirt



## Caveats ##

  * Currently vagrant-libvirt does only support system VMs
    (cf. https://github.com/pradels/vagrant-libvirt/issues/272).
