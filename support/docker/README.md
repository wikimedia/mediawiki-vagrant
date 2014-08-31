MediaWiki-Vagrant with Docker
=============================

The Dockerfile in this directory can be used along with the built-in Docker
provisioner provided with Vagrant 1.6.0+ to run the MediaWiki-Vagrant
application stack inside a Docker container.

This is not intended to be an example of the best way to use Docker. We are
attempting to use the lxc container managed by Docker as a full virtual
machine replacement rather than as a light weight service container. Once the
image is built and running, MediaWiki-Vagrant will run puppet inside the
container to provision a full stack MediaWiki development environment.

Recommended versions
--------------------
Vagrant: 1.6.0+
Docker: 1.1.0+

Usage
-----
* Install Vagrant 1.6.3
* Install Docker 1.1.0
* Install MediaWiki-Vagrant
* `./setup.sh`
* `vagrant config nfs_shares no`
* `vagrant up --provider=docker`

Tips
----

Directory permissions
~~~~~~~~~~~~~~~~~~~~~
Docker will mount your MediaWiki-Vagrant directory using device mapper
virtual block devices. This mounting arrangement provides good performance,
but there is no user mapping facility as is used for NFS or VirtualBox native
mounts. This means that the permissions on your host filesystem must allow the
'vagrant' and 'www-data' users to write to your vagrant and vagrant/logs
directories respectively. The vagrant user inside the Docker-managed container
will have uid 1000 and be a member of gid 1000 and 500. The 1000/1000 uid/gid
is the default for the first user created on an Ubuntu host system and may
serendipitously align with your user on the host system. Gid 500 matches the
"wikidev" group used in Wikimedia Labs.

Docker as default provisioner
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
In addition to the `--provider=docker` method of configuring Vagrant to use
the Docker provider, you can set the VAGRANT_DEFAULT_PROVIDER environment
variable: `export VAGRANT_DEFAULT_PROVIDER=docker`

Disabling NFS shares
~~~~~~~~~~~~~~~~~~~~
Vagrant and Docker currently do not play well with each other for using NFS
mounts. When NFS mounting is enabled, Vagrant will report a fatal error during
provisioning: "No host IP was given to the Vagrant core NFS helper. This is
an internal error that should be reported as a bug." This is tracked upstream
with Vagrant as <https://github.com/mitchellh/vagrant/issues/4011>.

Our Vagrantfile disables creating NFS shares when the Docker provider is in
use even if your host operating system supports NFS. You will need to run
`vagrant config nfs_shares no` to instruct MediaWiki-Vagrant to disable
attempting to use NFS for sharing. If you forget this step, Vagrant will give
you an error message similar to "The synced folder type 'nfs' is reporting as
unusable for your current setup. Please verify you have all the proper
prerequisites for using this shared folder type and try again."
