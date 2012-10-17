wmf-vagrant
===========

Skeleton Vagrant configuration for the Wikimedia Foundation. This is
a work-in-progress.

```bash
git clone https://github.com/atdt/wmf-vagrant.git
cd ./wmf-vagrant:
git submodule update --init
vagrant up
```

It'll take some time, because it'll need to fetch the base precise32 box if you
don't already have it. Once it's done, you should be able to browse to
http://127.0.0.1/w/ and see a vanilla MediaWiki install, served by the guest
VM, which is running Ubuntu Precise 32-bit.

The `mediawiki/` sub-folder in the repository is mounted as `/srv/mediawiki`,
and port 8080 on the host is forwarded to port 80 on the guest.
