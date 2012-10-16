wmf-vagrant
===========

Skeleton Vagrant configuration for the Wikimedia Foundation. This is a work-in-progress.

Running "vagrant up" from the repository root will provision a VM running
Ubuntu Precise 32-bit. The `mediawiki/` sub-folder in the repository will be
mounted as `/srv/mediawiki`, and port 8080 on the host will be forwarded to
port 80 on the guest.

Vagrant will invoke Puppet to provision the VM, using `manifests/base.pp`, which is currently blank. Modules may be added to `manifests/`. As an example, see [https://github.com/tombevers/vagrant-puppet-LAMP].
