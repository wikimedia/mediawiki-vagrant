[![wmf-vagrant][0]][1]


MediaWiki Vagrant
=================

A portable MediaWiki development environment.


## Prerequisites ##

You'll need to install [Vagrant][2] and [VirtualBox][3] (>= 4.1).

## Installation ##

```bash
git clone https://github.com/wikimedia/wmf-vagrant.git
cd ./wmf-vagrant
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

  [0]: https://raw.github.com/wikimedia/wmf-vagrant/master/modules/mediawiki/files/vagrant-wmf-logo.png
  [1]: http://travis-ci.org/atdt/snoflake
  [2]: http://vagrantup.com/v1/docs/getting-started/index.html
  [3]: https://www.virtualbox.org/wiki/Downloads
