![wmf-vagrant](https://raw.github.com/wikimedia/wmf-vagrant/master/modules/mediawiki/files/vagrant-wmf-logo.png)


MediaWiki Vagrant
=================

A portable MediaWiki development environment.


## Prerequisites ##

You'll need to install [Vagrant](http://vagrantup.com/v1/docs/getting-started/index.html) and [VirtualBox](https://www.virtualbox.org/wiki/Downloads) (>= 4.1).

**IMPORTANT**: You must enable hardware virtualization (VT-x or AMD-V).  This
is often a BIOS setting. If you don't do that, you'll probably get an error in
the last step of the installation, 'vagrant up'. You can verify this by trying
to launch the VM from the VirtualBox GUI. If an error message appears that says
something about "VT-X", you need to reboot the host machine and enable the BIOS
setting that allows hardware virtualization.

## Installation ##

```bash
git clone https://github.com/wikimedia/mediawiki-vagrant.git
cd ./mediawiki-vagrant
git submodule update --init
vagrant up
```

It'll take some time, because it'll need to fetch the base precise64 box if you
don't already have it. Once it's done, you should be able to browse to
http://127.0.0.1:8080/w/ and see a vanilla MediaWiki install, served by the guest
VM, which is running Ubuntu Precise 64-bit.

The `mediawiki/` sub-folder in the repository is mounted as `/srv/mediawiki`,
and port 8080 on the host is forwarded to port 80 on the guest.

The MySQL root credentials are:

* Username: root
* Password: vagrant

The MediaWiki credentials are:

* Username: admin
* Password: vagrant

To SSH into your VM, simply type `vagrant ssh`.

