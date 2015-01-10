MediaWiki-Vagrant Hackathon Distribution
========================================

Linux, Windows and OS X installers and git bundles to make setting up
MediaWiki-Vagrant easier and faster.


Installation instructions
-------------------------

NOTE: You can replace ~/Vagrant with your choice of directory, but
mediawiki must be directly underneath.

Replace /usb_drive with the location of the USB drive, or the location where
you copied the files from the drive.

1. If you don't have git installed (typically only windows users), install it
   from http://git-scm.com/downloads

2. If you don't have a Gerrit username yet, signup at
   https://wikitech.wikimedia.org/wiki/Special:UserLogin/signup .  The
   username you choose will be referred to below as GERRIT_USER .

3. From the directory for your OS, install VirtualBox.

4. From the directory for your OS, install Vagrant.  If you use Linux,
   use files from Linux/DEB/ for Debian or Ubuntu and Linux/RPM/ for Red Hat,
   Centos, Fedora, etc.

5. Install the virtual machine Vagrant uses as a base:

    $ cd /usb_drive
    $ vagrant box add trusty-cloud trusty-server-cloudimg-amd64-vagrant-disk1.box

6. Install the "vagrant-vbguest" Vagrant plugin:

    $ cd /usb_drive/Plugins
    $ vagrant plugin install vagrant-vbguest-0.10.0.gem

7. Clone MediaWiki-Vagrant from the provided git bundle file:

    $ cd /usb_drive
    $ git clone -b master mediawiki_vagrant.bundle ~/Vagrant

8. Copy pre-populated caches:

    $ cp -Rf cache ~/Vagrant/cache

9. Clone MediaWiki core from the provided git bundle file:

    $ git clone -b master mediawiki_core.bundle ~/Vagrant/mediawiki

10. Configure git repositories to sync with Gerrit:

    $ cd ~/Vagrant
    $ git remote set-url origin ssh://GERRIT_USER@gerrit.wikimedia.org:29418/mediawiki/vagrant.git

    $ cd ~/Vagrant/mediawiki
    $ git remote set-url origin ssh://GERRIT_USER@gerrit.wikimedia.org:29418/mediawiki/core.git

11. Update MediaWiki-Vagrant and MediaWiki core git repositories to latest
   versions:

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

For further information, see ~/Vagrant/README,
https://www.mediawiki.org/wiki/Gerrit/Tutorial and
https://www.mediawiki.org/wiki/MediaWiki-Vagrant .  You should follow
the steps above, rather than the installation instructions from the
other README or the "Quick start" on the wiki page.
