Using Parallels with MediaWiki-Vagrant
======================================

[Parallels Desktop][0] is a commercial virtualization application for OS X.

Setup
-----

Support for Parallels with MW-Vagrant requires some additional plugins,
[vagrant-parallels][1] which implements a `parallels` [provider][2], and
[vagrant-puppet-install][3] which ensures Puppet is installed to the base
Ubuntu image.

    vagrant plugin install vagrant-parallels
    vagrant plugin install vagrant-puppet-install

Use
---

    vagrant up --provider=parallels

Note that port forwarding works via localhost but not via external interfaces
of the host machine by default.

[0]: http://en.wikipedia.org/wiki/Parallels_Desktop_for_Mac
[1]: http://parallels.github.io/vagrant-parallels/
[2]: http://docs.vagrantup.com/v2/providers/
[3]: https://github.com/petems/vagrant-puppet-install
