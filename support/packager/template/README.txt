MediaWiki-Vagrant Hackathon Distribution
========================================

Linux, Windows and OS X installers and git bundles to make setting up
MediaWiki-Vagrant easier and faster, since most of the code is on the
USB drive.


Installation instructions
-------------------------

You must have a 64-bit processor (though your host OS can be 32-bit),
with hardware virtualization support enabled.  Many recent machines will have
this feature available, but you may need to turn it on.
See https://phabricator.wikimedia.org/diffusion/MWVA/browse/master/README.md for details.

NOTE: You can replace ~/Vagrant with your choice of directory, but
mediawiki must be directly underneath.

Replace /USB_DRIVE_PATH with the location of the USB drive, or the
location where you copied the files from the drive.

1. If you don't have git installed (typically only windows users),
   install it from the directory for your OS.

2. If you don't have a Gerrit username yet, signup at
   https://wikitech.wikimedia.org/wiki/Special:UserLogin/signup .  The
   "Instance shell account name" you give (not your Wiki username) is
   your username in Gerrit, replace GERRIT_USER in the instructions
   below with it.

3. From the directory for your OS, install VirtualBox.

4. From the directory for your OS, install Vagrant.  If you use Linux,
   use files from Linux/DEB/ for Debian or Ubuntu and Linux/RPM/ for Red
   Hat, Centos, Fedora, etc.

5. Install the virtual machine (an Ubuntu 14.04 "Trusty" Linux
   distribution) that Vagrant uses as a base:

    $ cd /USB_DRIVE_PATH
    $ vagrant box add trusty-cloud trusty-server-cloudimg-amd64-vagrant-disk1.box

6. Install the "vagrant-vbguest" Vagrant plugin:

    $ cd /USB_DRIVE_PATH/Plugins
    $ vagrant plugin install vagrant-vbguest-0.10.0.gem

7. Clone MediaWiki-Vagrant from the provided git bundle file:

    $ cd /USB_DRIVE_PATH
    $ git clone -b master mediawiki_vagrant.bundle ~/Vagrant

8. Copy pre-populated caches:

    $ cp -Rf cache/* ~/Vagrant/cache

9. Clone MediaWiki core from the provided git bundle file:

    $ git clone -b master mediawiki_core.bundle ~/Vagrant/mediawiki

9a. You're done with the USB drive, you can unmount/safely remove it.

10. You've got fairly recent code off the USB drive, but development
    continues. Configure git repositories to sync with Gerrit over
    the network:

    $ cd ~/Vagrant
    $ git remote set-url origin ssh://GERRIT_USER@gerrit.wikimedia.org:29418/mediawiki/vagrant.git

    $ cd ~/Vagrant/mediawiki
    $ git remote set-url origin ssh://GERRIT_USER@gerrit.wikimedia.org:29418/mediawiki/core.git

11. Update MediaWiki-Vagrant and MediaWiki core git repositories to
    latest versions:

   $ cd ~/Vagrant
   $ git pull
   $ git submodule update --init --recursive
   $ git checkout -- .

   $ cd ~/Vagrant/mediawiki
   $ git pull

12. Start your MediaWiki-Vagrant virtual machine for the first time:

    $ cd ~/Vagrant
    $ ./setup.sh
    $ vagrant up

After `vagrant up` is complete, you can test in your browser at
http://127.0.0.1:8080/ .


Other resources
---------------

For further information, see ~/Vagrant/README.md,
https://www.mediawiki.org/wiki/Gerrit/Tutorial and
https://www.mediawiki.org/wiki/MediaWiki-Vagrant .  You should follow
the steps above, rather than the installation instructions from the
other README or the "Quick start" on the wiki page.
