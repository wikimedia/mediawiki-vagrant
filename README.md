MediaWiki-Vagrant
=================

MediaWiki-Vagrant is a portable MediaWiki development environment. It consists
of a set of configuration scripts that automate the creation of a virtual
machine that runs MediaWiki.

The virtual machine that MediaWiki-Vagrant creates makes it easy to learn
about, modify, and improve MediaWiki's code: useful debugging information is
displayed by default, and various developer tools are set up specifically for
inspecting and interacting with MediaWiki code, including a powerful debugger
and an interactive interpreter. Best of all, because the configuration is
automated and contained in a virtual environment, mistakes are easy to undo.

See https://www.mediawiki.org/wiki/MediaWiki-Vagrant for more information.

Install
-------

You'll need to install recent versions of Vagrant and VirtualBox.

(Note that *experimental* support for Parallels, LXC, libvirt
(KVM/QEMU), VMWare Fusion, and Microsoft Hyper-V providers exists.
See `support/README-libvirt.md` `support/README-lxc.md` or
`support/README-parallels.md` for details on the former three.)

 * VirtualBox: https://www.virtualbox.org/wiki/Downloads
 * Vagrant: https://www.vagrantup.com/downloads-archive.html (the version must
   be 1.7.0 or higher).

   To check your Vagrant version, run

     `vagrant --version`

   in a directory without a Vagrantfile (for example in your home directory).
 * You must have a 64-bit processor (although your host OS can be 32-bit).

   Hardware virtualization extensions must be enabled in your host computer
   BIOS. The BIOS setting is usually in the "Chipset", "Processor", "CPU", or
   "Security Settings" menu and may be labeled as "VT-x", "Intel
   Virtualization Technology", "Virtualization Extensions", "Vanderpool"
   "AMD-V" or various other names depending on the OEM and system BIOS.
 * (Optional) For better performance on non-Windows hosts, install NFS.  For
   Debian-based systems (including Ubuntu), run:

    `sudo apt-get install nfs-kernel-server portmap`

   You can optionally configure sudo not to prompt you for the password when
   doing operations related to this NFS service.  See
   https://www.vagrantup.com/docs/synced-folders/nfs.html#root-privilege-requirement

Next, you'll need a copy of the mediawiki-vagrant project files.

 * zip: https://github.com/wikimedia/mediawiki-vagrant/archive/master.zip
 * tar.gz: https://github.com/wikimedia/mediawiki-vagrant/archive/master.tar.gz
 * Git: `git clone https://gerrit.wikimedia.org/r/mediawiki/vagrant`

If you've downloaded the zip file or tarball, you will need to extract it to a
directory of your choice. Once you do that, open up a terminal or a
command-prompt, and change your working directory to the location of the
extracted (or git-cloned) files.

If you have cloned the git repository you will also need to clone the
submodules with:

    git submodule update --init --recursive

You can combine cloning the base repo and its submodules with:

    git clone --recursive https://gerrit.wikimedia.org/r/mediawiki/vagrant

Run the appropriate setup script for your platform. For Windows, run
`setup.bat`. For Linux and OS X, run `setup.sh`. Some extra Vagrant plugins,
including the bundled mediawiki-vagrant plugin, will be installed.

From there, run `vagrant up` to provision and boot the virtual machine.

You'll now have to wait a bit, as Vagrant needs to retrieve the base image from
Canonical, retrieve some additional packages, and install and configure each of
them in turn.

If it all worked, you should be able to browse to
http://dev.wiki.local.wmftest.net:8080/ and see the main page of your
MediaWiki instance.


Use
---

To access a command shell on your virtual environment, run `vagrant ssh` from
the root mediawiki-vagrant directory or any of its subdirectories.

From there, run `mwrepl` to interactively evaluate PHP code in a MediaWiki
context, or `mysql` to get an authenticated SQL shell on your wiki's database.
If you have multiple wikis enabled, you can run `mwrepl <dbname>` where
`<dbname>` is the database name for that wiki (for example `mwrepl frwiki`).

The default MediaWiki admin account has the username `admin` and password
`vagrant`.


Update
------

When the vagrant Virtual Machine is running, it will periodically run Puppet
(an open source configuration management tool) to update its configuration,
which keeps various software packages up to date. To avoid clobbering any
changes you may have made to MediaWiki's source code, Puppet will not update
MediaWiki.

To pick up other changes to the install, on the host computer in the directory
with the vagrant files run `git pull --rebase` and then `vagrant reload`.
The latter will restart the VM.
If you see a “no wiki found” error afterwards, try running
`sudo systemctl restart apache2` in the VM (i. e. inside a `vagrant ssh` shell).


Extend
------

You can add roles to MediaWiki-Vagrant! A 'role' represents a set of software
configurations required for giving this machine some special function.
Mediawiki-Vagrant has several commands to manage enabled roles.
See `vagrant roles -h` for help on usage.

If you'd like to use the Mediawiki-Vagrant codebase to describe a development
environment that you could then share with other developers, you should do so
by adding a role file to puppet/modules/role/manifests/ and submitting it as a
patch to the Mediawiki-Vagrant project.


Settings
--------

For information about settings, see settings.d/README.

Testing
-------

Install dependencies:

    (sudo) gem install bundler
    bundle install

Run linter, test and doc generation commands:

    bundle exec rake

Troubleshoot
------------

Stuck? Here's where to get help.

 * https://www.mediawiki.org/wiki/Mediawiki-Vagrant#Troubleshooting
 * irc://irc.libera.chat/#mediawiki

Please report any bugs on Wikimedia's Phabricator:
 * https://phabricator.wikimedia.org/maniphest/task/create/?projects=MediaWiki-Vagrant

Patches and contributions are welcome!
See <https://www.mediawiki.org/wiki/How_to_become_a_MediaWiki_hacker> for
details.
